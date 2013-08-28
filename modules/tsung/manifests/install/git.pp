class tsung::install::git ($target_dir = '/opt/tsung') {

    $tsung_src = '/usr/src/tsung-588cfed3'

    vcsrepo { $tsung_src:
        ensure    => latest,
        provider  => git,
        source    => 'https://github.com/processone/tsung',
        revision  => '588cfed3ece6c1a1a9b942d2f1e4969ede6d526f',
    }

    exec { 'tsung_configure':
        cwd         => $tsung_src,
        command     => "${tsung_src}/configure --prefix=/opt/tsung",
        unless      => 'test -d /opt/tsung',
        require     => Vcsrepo[$tsung_src],
    }

    exec { 'tsung_make_install':
        cwd         => $tsung_src,
        command     => 'make && make install',
        creates     => '/opt/tsung',
        require     => Exec['tsung_configure'],
    }
}
