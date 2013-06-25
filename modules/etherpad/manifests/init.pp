class etherpad (
        $listen_address,
        $session_key,
        $api_key,

        $oae_db_hosts,
        $oae_db_keyspace,
        $oae_db_replication,
        $oae_db_strategy_class,

        $install_method         = 'package',
        $package_name           = 'etherpad-lite',
        $package_version        = '1.2.91-4',
        $etherpad_dir           = '/opt/etherpad',
        $etherpad_git_revision  = '1.2.91',
        $ep_oae_git_revision    = 'master',
        $etherpad_user          = 'etherpad',
        $service_name           = 'etherpad',
        $enable_abiword         = false) {


    # Install etherpad.
    class {'etherpad::install':
        etherpad_dir            => $etherpad_dir,
        install_method          => $install_method,
        package_name            => $package_name,
        package_version         => $package_version,
        etherpad_git_revision   => $etherpad_git_revision,
        ep_oae_git_revision     => $ep_oae_git_revision,
    }

    if ($enable_abiword) {
        package { 'abiword':
            ensure => present,
        }
    }


    user { "${etherpad_user}": ensure => present }

    # Apply our custom settings.json file
    file { "${etherpad_dir}/settings.json":
        ensure      =>  present,
        mode        =>  '0644',
        content     =>  template('etherpad/etherpad.settings.json.erb'),
        require     =>  Class['etherpad::install'],
    }

    # The file that will contain the shared secret.
    file { "${etherpad_dir}/APIKEY.txt":
        ensure      =>  present,
        content     =>  $api_key,
        mode        =>  '0644',
        require     =>  Class['etherpad::install'],
    }

    exec { "chown_etherpad_dir":
        command    => "chown -R ${etherpad_user}:${etherpad_user} ${etherpad_dir}",
        cwd        => $etherpad_dir,
        require    => [ File["${etherpad_dir}/APIKEY.txt"], User[$etherpad_user] ]
    }

    # Daemon script for the etherpad service
    file { "/etc/init/${service_name}.conf":
        ensure  =>  present,
        content =>  template('etherpad/upstart_etherpad.conf.erb'),
        require =>  Class['etherpad::install'],
    }

    # Start the etherpad server
    service { $service_name:
        ensure      => running,
        provider    => upstart,
        require     => [
            Exec['chown_etherpad_dir'],
            File["/etc/init/${service_name}.conf"]
        ]
    }
}
