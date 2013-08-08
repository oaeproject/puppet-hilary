class tsung::install::archive ($target_dir = '/opt/tsung', $version = '1.5.0') {
    
    archive { 'tsung':
        url         => "http://tsung.erlang-projects.org/dist/tsung-${version}.tar.gz",
        target      => '/usr/src',
        checksum    => false,
    }

    exec { 'tsung_configure':
        cwd         => '/usr/src/tsung',
        command     => 'configure --prefix=/opt/tsung',
        unless      => 'test -d /opt/tsung',
        require     => Archive['tsung'],
    }

    exec { 'tsung_make_install':
        cwd         => '/usr/src/tsung',
        command     => 'make && make install',
        creates     => '/opt/tsung',
        require     => Exec['tsung_configure'],
    }
}