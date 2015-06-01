class etherpad (
        $listen_address,
        $session_key,
        $api_key,

        $oae_db_hosts,
        $oae_db_keyspace,
        $oae_db_replication,
        $oae_db_strategy_class,

        $oae_mq_hosts,

        $install_method         = 'archive',
        $install_config         = {
            'url_base'              => 'https://s3.amazonaws.com/oae-releases/etherpad',
            'version_major_minor'   => '1.4',
            'version_patch'         => '0-63-14f9c91',
            'version_nodejs'        => '0.10.17',
        },

        $etherpad_dir           = '/opt/etherpad',
        $etherpad_user          = 'etherpad',
        $service_name           = 'etherpad',
        $enable_abiword         = false) {

    # Install etherpad
    class { "::etherpad::install::${install_method}":
        install_config      => $install_config,
        etherpad_root_dir   => $etherpad_dir,
    }

    if ($enable_abiword) {
        package { 'abiword':
            ensure => present,
        }
    }

    package { 'tidy':
        ensure => present,
    }

    user { "${etherpad_user}": ensure => present }

    # Install the custom CSS for etherpad from the ep_oae plugin. This is being put in
    # both the src/ and ep_etherpad-lite/ because the symlink from ep_etherpad-lite
    # to src/ gets lost when tarring up the directory for releases
    file { "${etherpad_dir}/node_modules/ep_etherpad-lite/static/custom/pad.css":
        ensure     => present,
        source     => "${etherpad_dir}/node_modules/ep_oae/static/css/pad.css",
        require    => Class["::etherpad::install::${install_method}"],
    }

    file { "${etherpad_dir}/src/static/custom/pad.css":
        ensure     => present,
        source     => "${etherpad_dir}/node_modules/ep_oae/static/css/pad.css",
        require    => Class["::etherpad::install::${install_method}"],
    }

    # Overwrite ep_headings editbarButton template file
    file { "${etherpad_dir}/node_modules/ep_headings2/templates/editbarButtons.ejs":
        ensure     => present,
        source     => "${etherpad_dir}/node_modules/ep_oae/static/templates/editbarButtons.ejs",
        require    => Class["::etherpad::install::${install_method}"],
    }

    # Apply our custom settings.json file
    file { 'etherpad_settings_json':
        path    => "${etherpad_dir}/settings.json",
        ensure  => present,
        mode    => '0644',
        content => template('etherpad/etherpad.settings.json.erb'),
        require => Class["::etherpad::install::${install_method}"],
    }

    # The file that will contain the shared secret
    file { 'etherpad_apikey_txt':
        path    => "${etherpad_dir}/APIKEY.txt",
        ensure  => present,
        content => $api_key,
        mode    => '0644',
        require => Class["::etherpad::install::${install_method}"],
    }

    # Ensure that the /var directory exists and is writeable by the Etherpad user
    # as this is the directory that contains the minified assets
    file { 'etherpad_var_dir':
        path    => "${etherpad_dir}/var",
        ensure  => directory,
        mode    => "744",
    }

    # Ensure the etherpad user owns all the etherpad resources
    exec { 'chown_etherpad_dir':
        command => "chown -R ${etherpad_user}:${etherpad_user} ${etherpad_dir}",
        cwd     => $etherpad_dir,
        require => [File['etherpad_apikey_txt'], File['etherpad_var_dir'], User[$etherpad_user]],
    }

    # Daemon script for the etherpad service
    file { 'etherpad_service':
        path    => "/etc/init/${service_name}.conf",
        ensure  => present,
        content => template('etherpad/upstart_etherpad.conf.erb'),
        require => [Class["::etherpad::install::${install_method}"]],
    }

    # Start the etherpad server
    service { $service_name:
        ensure      => running,
        provider    => upstart,
        require     => [
            File["${etherpad_dir}/node_modules/ep_etherpad-lite/static/custom/pad.css"],
            File["${etherpad_dir}/node_modules/ep_headings2/templates/editbarButtons.ejs"],
            File["${etherpad_dir}/src/static/custom/pad.css"],
            File['etherpad_settings_json'],
            File['etherpad_apikey_txt'],
            Exec['chown_etherpad_dir'],
            File['etherpad_service'],
        ],
    }
}
