class oracle-java (
        $file_name    = 'jdk-6u45-linux-x64.bin',
        $package_name = 'jdk1.6.0_45'
    ) {

    file { '/usr/lib/jvm/':
        ensure => directory,
    }

    file { "/usr/lib/jvm/${file_name}":
        ensure  => present,
        mode    => 700,
        source  => "puppet:///modules/oracle-java/${file_name}",
        require => File['/usr/lib/jvm/'],
        notify  => Exec['unpack-java'],
    }

    exec { 'unpack-java':
        command     => $file_name,
        cwd         => '/usr/lib/jvm/',
        path        => '/usr/lib/jvm/',
        refreshonly => true,
        notify      => Alternatives['java'],
    }

    exec { 'update-alternatives':
        command     => "update-alternatives --install /usr/bin/java java /usr/lib/jvm/${package_name}/jre/bin/java 1; update-alternatives --set java /usr/lib/jvm/${package_name}/jre/bin/java",
        cwd         => '/',
        refreshonly => true,
    }
}
