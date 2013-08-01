class hilary::install::git ($install_config, $app_root_dir = '/opt/oae') {
    require ::oaeservice::deps::package::git

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
        command     => 'npm install -d',
        logoutput   => 'on_failure',

        # Exec['npm_reinstall_nodegyp'] is a dependency currently in oaeservice::deps::package::nodejs which ensures nodegyp is the proper version. It's put here because if the dependencies are not assembled properly this failure would be hard to track down
        require     => [ File[$app_root_dir], Vcsrepo[$app_root_dir], Exec['npm_reinstall_nodegyp'] ],
    }

    # chown the application root to the app user again
    exec { 'app_root_dir_chown':
        cwd         => $app_root_dir,
        command     => "chown -R $os_user:$os_group .",
        logoutput   => "on_failure",
        require     => [ Exec["npm_install_dependencies"] ],
    }
}
