class etherpad (
        $listen_address,
        $session_key,
        $api_key,

        $oae_db_hosts,
        $oae_db_keyspace,
        $oae_db_replication,
        $oae_db_strategy_class,
        $oae_sign_key,

        $etherpad_git_revision  = 'consolefix',
        $etherpad_dir           = '/opt/etherpad',
        $ep_oae_path            = '/opt/etherpad/node_modules/ep_oae',
        $ep_oae_revision        = 'master',
        $etherpad_user          = 'etherpad',
        $service_name           = 'etherpad',
        $enable_abiword         = false) {


    if ($enable_abiword) {
        package { 'abiword':
            ensure => present,
        }
    }


    user { "${etherpad_user}": ensure => present }

    # Get the etherpad source
    vcsrepo { $etherpad_dir:
        ensure      =>  present,
        provider    =>  git,
        source      =>  'https://github.com/simong/etherpad-lite',
        revision    =>  $etherpad_git_revision,
    }

    # Apply our custom settings.json file
    file { "${etherpad_dir}/settings.json":
        ensure      =>  present,
        mode        =>  '0644',
        content     =>  template('etherpad/etherpad.settings.json.erb'),
        require     =>  Vcsrepo[$etherpad_dir],
    }

    # Install the etherpad npm dependencies
    exec { 'install_etherpad_dependencies':
        command     =>  "${$etherpad_dir}/bin/installDeps.sh",
        cwd         =>  $etherpad_dir,
        require     =>  Vcsrepo[$etherpad_dir],
    }

    # Install the OAE etherpad plugin
    vcsrepo { $ep_oae_path:
        ensure      =>  present,
        provider    =>  git,
        source      =>  'https://github.com/oaeproject/ep_oae',
        revision    =>  $ep_oae_revision,
        require     =>  Exec['install_etherpad_dependencies'],
    }

    # Copy the pad.css file.
    file { "${$etherpad_dir}/src/static/custom/pad.css":
        ensure      => 'link',
        target      => "${$etherpad_dir}/node_modules/ep_oae/static/css/pad.css",
    }

    # Install the ep_headings plugin
    exec { "install_ep_headings":
        command     => "npm install ep_headings",
        cwd         => $etherpad_dir,
        require     => Exec['install_etherpad_dependencies'],
    }

    # The file that will contain the shared secret.
    file { "${etherpad_dir}/APIKEY.txt":
        ensure      =>  present,
        content     =>  $api_key,
        mode        =>  '0644',
        require     =>  [ Vcsrepo[$etherpad_dir], Vcsrepo[$ep_oae_path] ]
    }

    exec { "chown_etherpad_dir":
        command    => "chown -R ${etherpad_user}:${etherpad_user} ${etherpad_dir}",
        cwd        => $etherpad_dir,
        require    => [ File["${etherpad_dir}/APIKEY.txt"], User[$etherpad_user], Exec['install_ep_headings'] ]
    }

    # Daemon script for the etherpad service
    file { "/etc/init/${service_name}.conf":
        ensure  =>  present,
        content =>  template('etherpad/upstart_etherpad.conf.erb'),
        require =>  [ Vcsrepo[$etherpad_dir], Vcsrepo[$ep_oae_path] ],
    }

    # Start the etherpad server
    service { $service_name:
        ensure      => running,
        provider    => upstart,
        require     => [
            Vcsrepo[$ep_oae_path],
            Exec['install_etherpad_dependencies'],
            File["/etc/init/${service_name}.conf"]
        ]
    }
}
