class hilary::install::git ($install_config, $app_root_dir = '/opt/oae') {
    require ::oaeservice::deps::package::git

    if ! $nodejs_version {
      $nodejs_version = hiera('global_nodejs_version')
    }

    $_install_config = merge({
        'source'    => 'https://github.com/oaeproject/Hilary',
        'revision'  => 'master'
    }, $install_config)

    # git clone https://github.com/oaeproject/Hilary
    vcsrepo { $app_root_dir:
        ensure    => latest,
        provider  => git,
        source    => $_install_config['source'],
        revision  => $_install_config['revision'],
    }

    # We need to chown the directory before we can do an npm install
    file { $app_root_dir:
        ensure  => directory,
        mode    => "0644",
        owner   => $os_user,
        group   => $os_group,
        require => Vcsrepo[$app_root_dir],
    }

    # npm install -d
    exec { "npm_install_dependencies":
        cwd         => $app_root_dir,

        # Forcing CFLAGS for std=c99 for hiredis, until https://github.com/pietern/hiredis-node/pull/33 is resolved
        environment => ['CFLAGS="-std=c99"', 'HOME=/root'],
        command     => "/usr/local/$nodejs_version/bin/npm install -d",
        logoutput   => 'on_failure',
    }

    # chown the application root to the app user again
    exec { 'app_root_dir_chown':
        cwd         => $app_root_dir,
        command     => "chown -R $os_user:$os_group .",
        logoutput   => "on_failure",
        require     => [ Exec["npm_install_dependencies"] ],
    }
}
