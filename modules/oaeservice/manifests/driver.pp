class oaeservice::driver {
    include ::oaeservice::deps::common
    include ::oaeservice::deps::package::erlang
    include ::oaeservice::deps::package::gnuplot
    include ::oaeservice::deps::package::graphicsmagick
    include ::oaeservice::deps::package::nodejs
    include ::tsung::install::git

    Class['::oaeservice::deps::package::erlang']    -> Class['::tsung::install::git']
    Class['::oaeservice::deps::package::git']       -> Vcsrepo<| |>


    # Install OAE-model-loader and node-oae-tsung

    $oae_tsung_dir = '/opt/node-oae-tsung'
    $oae_loader_dir = '/opt/OAE-model-loader'

    vcsrepo { $oae_tsung_dir:
        ensure      => latest,
        provider    => git,
        source      => 'https://github.com/oaeproject/node-oae-tsung',
        revision    => 'master',
    }

    exec { 'npm_install_tsung':
        cwd     => $oae_tsung_dir,
        command => 'npm install -d',
        require => Vcsrepo[$oae_tsung_dir]
    }

    vcsrepo { $oae_loader_dir:
        ensure      => latest,
        provider    => git,
        source      => 'https://github.com/oaeproject/OAE-model-loader',
        revision    => 'master',
    }

    exec { 'npm_install_modelloader':
        cwd     => $oae_loader_dir,
        command => 'npm install -d',
        require => [Class['::oaeservice::deps::package::nodejs'], Vcsrepo[$oae_loader_dir]]
    }

    # Install Nginx, so we have a place to put the data
    package { 'nginx': }
    service { 'nginx':
        ensure  => running,
        require => Package['nginx'],
    }
}
