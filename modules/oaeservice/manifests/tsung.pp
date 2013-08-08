class oaeservice::tsung {
    include ::oaeservice::deps::common
    include ::oaeservice::deps::package::erlang
    include ::oaeservice::deps::package::gnuplot
    include ::oaeservice::deps::package::graphicsmagick
    include ::oaeservice::deps::package::nodejs
    include ::tsung::install::archive

    Class['::oaeservice::deps::package::erlang']    -> Class['::tsung::install::archive']
    Class['::oaeservice::deps::package::git']       -> Vcsrepo<| |>

    vcsrepo { '/opt/node-oae-tsung':
        ensure      => latest,
        provider    => git,
        source      => 'https://github.com/oaeproject/node-oae-tsung',
        revision    => 'master',
    }

    vcsrepo { '/opt/OAE-model-loader':
        ensure      => latest,
        provider    => git,
        source      => 'https://github.com/oaeproject/OAE-model-loader',
        revision    => 'master',
    }
}