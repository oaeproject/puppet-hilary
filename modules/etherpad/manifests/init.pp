class etherpad (
        $listen_address,
        $session_key,
        $api_key,

        $oae_db_hosts,
        $oae_db_keyspace,
        $oae_db_replication,
        $oae_db_strategy_class,

        $install_method         = 'archive',
        $install_config         = {
            'url_base'              => 'https://s3.amazonaws.com/oae-releases/etherpad',
            'version_major_minor'   => '1.2',
            'version_patch'         => '91',
            'version_nodejs'        => '0.10.17',
        },

        $etherpad_dir           = '/opt/etherpad',
        $etherpad_git_source    = 'https://github.com/ether/etherpad-lite',
        $etherpad_git_revision  = '1.2.91',
        $ep_oae_git_source      = 'https://github.com/oaeproject/ep_oae',
        $ep_oae_git_revision    = 'master',
        $etherpad_user          = 'etherpad',
        $service_name           = 'etherpad',
        $enable_abiword         = false) {

    # Install etherpad
    class { "::etherpad::install::${install_method}":
        install_config      => $install_config,
        etherpad_root_dir   => $etherpad_dir,
    }

    Class["::etherpad::install::${install_method}"] -> File['etherpad_settings_json']
    Class["::etherpad::install::${install_method}"] -> File['etherpad_apikey_txt']
    Class["::etherpad::install::${install_method}"] -> File['etherpad_service']

    if ($enable_abiword) {
        package { 'abiword':
            ensure => present,
        }
    }

    user { "${etherpad_user}": ensure => present }

    # Apply our custom settings.json file
    file { 'etherpad_settings_json':
        path        =>  "${etherpad_dir}/settings.json",
        ensure      =>  present,
        mode        =>  '0644',
        content     =>  template('etherpad/etherpad.settings.json.erb'),
        require     => Class["::etherpad::install::${install_method}"]
    }

    # The file that will contain the shared secret.
    file { 'etherpad_apikey_txt':
        path        => "${etherpad_dir}/APIKEY.txt",
        ensure      =>  present,
        content     =>  $api_key,
        mode        =>  '0644',
    }

    exec { "chown_etherpad_dir":
        command    => "chown -R ${etherpad_user}:${etherpad_user} ${etherpad_dir}",
        cwd        => $etherpad_dir,
        require    => [ File['etherpad_apikey_txt'], User[$etherpad_user] ]
    }

    # Daemon script for the etherpad service
    file { 'etherpad_service':
        path    => "/etc/init/${service_name}.conf",
        ensure  =>  present,
        content =>  template('etherpad/upstart_etherpad.conf.erb'),
    }

    # Start the etherpad server
    service { $service_name:
        ensure      => running,
        provider    => upstart,
        require     => [
            Exec['chown_etherpad_dir'],
            File['etherpad_service']
        ]
    }
}
