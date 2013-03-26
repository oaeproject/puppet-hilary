class etherpad (
        listen_address,
        $provider               = 'pkgin',
        $etherpad_git_branch    = 'master',
        $api_key                = 'rlfGwIPGisZirBjlWPWiavkL8sk4vi2rXsh1Kml5zWxJbiZ1zkWnKDBL1k6s',
        $etherpad_dir           = '/opt/etherpad-lite',
        $etherpad_oae_plugin    = '/opt/etherpad-lite/node_modules/ep_oae',
        $etherpad_user          = 'admin',
        $etherpad_group         = 'staff',
        $service_name           = 'node-etherpad') {

    $packages = ['nodejs', 'npm', 'scmgit']



    # Ensure that the required OS dependencies are installed.
    package { $packages:
        ensure      =>  installed,
        provider    =>  $provider,
    }

    # Get the etherpad source
    vcsrepo { $etherpad_dir:
        ensure      =>  present,
        provider    =>  git,
        source      =>  'http://github.com/ether/etherpad-lite',
        revision    =>  $etherpad_git_branch,
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
    vcsrepo { $etherpad_oae_plugin:
        ensure      =>  present,
        provider    =>  git,
        source      =>  'http://github.com/sakaiproject/ep_oae',
        revision    =>  'master',
        require     =>  Exec['install_etherpad_dependencies'],
    }

    # The file that will contain the shared secret.
    file { "${etherpad_dir}/APIKEY.txt":
        ensure      =>  present,
        content     =>  $api_key,
        mode        =>  '0644',
        require     =>  [ Vcsrepo[$etherpad_dir], Vcsrepo[$etherpad_oae_plugin] ]
    }

    exec { "chown_etherpad_dir": 
        command    => "/opt/local/gnu/bin/chown -R ${etherpad_user}:${etherpad_group} ${etherpad_dir}",
        cwd        => $etherpad_dir,
        require    => [ File["${etherpad_dir}/APIKEY.txt"] ]
    }

    # Daemon script needed for SMF to manage the application
    file { "${etherpad_dir}/service.xml":
        ensure      =>  present,
        content     =>  template('etherpad/node-etherpad-service-manifest.xml.erb'),
        notify      =>  Exec["svccfg_${service_name}"],
        require     =>  [ Vcsrepo[$etherpad_dir], Vcsrepo[$etherpad_oae_plugin] ],
    }

    # Force reload the manifest
    exec { "svccfg_${service_name}":
        command     =>  "/usr/sbin/svccfg import ${etherpad_dir}/service.xml",
        require     =>  File["${etherpad_dir}/service.xml"],
    }

    # Start the etherpad server
    service { $service_name:
        ensure      =>  running,
        manifest    =>  "${app_root_dir}/service.xml",
        require     =>  [ Vcsrepo[$etherpad_oae_plugin], Exec['install_etherpad_dependencies'], Exec["svccfg_${service_name}"] ]
    }
}
