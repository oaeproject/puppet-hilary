class oracle-java (
        $file_name    = 'jdk-7u65-linux-x64.gz',
        $package_name = 'jdk1.7.0_65'
    ) {


    file { '/usr/lib/jvm/':
        ensure => directory,
    }

    file { "/usr/lib/jvm/${file_name}":
        ensure  => present,
        mode    => 700,
        source  => "puppet:///modules/oracle-java/${file_name}",
        require => File['/usr/lib/jvm/'],
        notify  => Exec['install-java'],
    }

    exec { 'install-java':
        command     => "/bin/tar -xzvf $file_name",
        cwd         => '/usr/lib/jvm/',
        refreshonly => true,
        notify      => Exec['update-alternatives'],
    }

    exec { 'update-alternatives':
        command     => "update-alternatives --install /usr/bin/java java /usr/lib/jvm/${package_name}/jre/bin/java 1; update-alternatives --set java /usr/lib/jvm/${package_name}/jre/bin/java",
        cwd         => '/',
        refreshonly => true,
    }
}

