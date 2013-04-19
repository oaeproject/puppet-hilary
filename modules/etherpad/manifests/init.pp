class etherpad (
        $listen_address,
        $session_key,
        $api_key,
        
        $oae_db_hosts,
        $oae_db_keyspace,
        $oae_db_replication,
        $oae_db_strategy_class,
        $oae_sign_key,

        $etherpad_git_revision  = 'master',
        $etherpad_dir           = '/opt/etherpad',
        $ep_oae_path            = '/opt/etherpad/node_modules/ep_oae',
        $ep_oae_revision        = 'master'
        $etherpad_user          = 'etherpad',
        $etherpad_group         = 'etherpad',
        $service_name           = 'etherpad') {

    # Get the etherpad source
    vcsrepo { $etherpad_dir:
        ensure      =>  present,
        provider    =>  git,
        source      =>  'http://github.com/ether/etherpad-lite',
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

    # Install the Sakai OAE etherpad plugin
    vcsrepo { $ep_oae_path:
        ensure      =>  present,
        provider    =>  git,
        source      =>  'http://github.com/sakaiproject/ep_oae',
        revision    =>  $ep_oae_revision,
        require     =>  Exec['install_etherpad_dependencies'],
    }

    # The file that will contain the shared secret.
    file { "${etherpad_dir}/APIKEY.txt":
        ensure      =>  present,
        content     =>  $api_key,
        mode        =>  '0644',
        require     =>  [ Vcsrepo[$etherpad_dir], Vcsrepo[$ep_oae_path] ]
    }

    exec { "chown_etherpad_dir": 
        command    => "/opt/local/gnu/bin/chown -R ${etherpad_user}:${etherpad_group} ${etherpad_dir}",
        cwd        => $etherpad_dir,
        require    => [ File["${etherpad_dir}/APIKEY.txt"] ]
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
