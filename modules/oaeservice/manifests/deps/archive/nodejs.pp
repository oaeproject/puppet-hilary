class oaeservice::deps::archive::nodejs {

    if ! $nodejs_version {
        $nodejs_version = hiera('global_nodejs_version')
    }
    $nodejs_base_url = hiera('nodejs_base_url')

    # Download and unpack the archive
    archive { "node-package":
        ensure          => present,
        url             => "$nodejs_base_url/$nodejs_version/node-$nodejs_version-linux-x64.tar.gz",
        target          => '/usr/local',
        checksum        => false,
        extension       => 'tar.gz',
    }

    file { "node_dir_symlink":
        path   => "/usr/local/$nodejs_version",
        ensure => link,
        target => "/usr/local/node-$nodejs_version-linux-x64",
    }

    file { "node_symlink":
        path   => "/usr/bin/node",
        ensure => link,
        target => "/etc/alternatives/node",
    }

    file { "node_alternative_symlink":
        path   => "/etc/alternatives/node",
        ensure => link,
        target => "/usr/local/$nodejs_version/bin/node",
    }

    file { "npm_symlink":
        path   => "/usr/bin/npm",
        ensure => link,
        target => "/etc/alternatives/npm",
    }

    file { "npm_alternative_symlink":
        path   => "/etc/alternatives/npm",
        ensure => link,
        target => "/usr/local/$nodejs_version/bin/npm",
    }

}
