class oaeservice::deps::archive::nodejs {

    if ! $nodejs_version {
      $nodejs_version = hiera('global_nodejs_version')
    }
    $nodejs_base_url = hiera('nodejs_base_url')

    # Download and unpack the archive
    archive { "node-v6.11.1":
        ensure          => present,
        url             => "$nodejs_base_url/$nodejs_version/node-$nodejs_version-linux-x64.tar.gz",
        target          => '/usr/local',
        checksum        => false,
        extension       => 'tar.gz',
    }

    file { "node_symlink":
      path => "/usr/local/$nodejs_version",
      ensure => link,
      target => "/usr/local/node-$nodejs_version-linux-x64",
    }


}

