class tsung::install::archive ($target_dir = '/opt/tsung', $version = '1.5.0') {
    
    archive { 'tsung':
        url         => "http://tsung.erlang-projects.org/dist/tsung-${version}.tar.gz",
        target      => '/usr/src',
        checksum    => false,
    }

    $tsung_src = "/usr/src/tsung-${version}"

    exec { 'tsung_configure':
        cwd         => $tsung_src,
        command     => './configure --prefix=/opt/tsung',
        unless      => 'test -d /opt/tsung',
        require     => Archive['tsung'],
    }

    exec { 'tsung_make_install':
        cwd         => $tsung_src,
        command     => 'make && make install',
        creates     => '/opt/tsung',
        require     => Exec['tsung_configure'],
    }
}