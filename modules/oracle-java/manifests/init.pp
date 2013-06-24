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

    alternatives { 'java': path => $java_path }
}
