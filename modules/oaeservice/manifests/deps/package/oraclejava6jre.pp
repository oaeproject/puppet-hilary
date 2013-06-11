class oaeservice::deps::package::oraclejava6jre {
    
    $script_dir = '/opt'

    # Use the Archive module to download and md5 the script for convenience
    archive::download { 'oab-java.sh':
        url             => 'https://raw.github.com/flexiondotorg/oab-java6/0.2.8/oab-java.sh',
        src_target      => $script_dir,
        digest_string   => 'b145cf455f3dd1ea116d81088ca5620e',
    }

    file { 'oab-java.sh':
        path    => "$script_dir/oab-java.sh",
        mode    => 0744,
        require => Archive::Download['oab-java.sh'],
    }

    # Allow 5min to download and install java
    exec { 'oab-java.sh':
        command => "$script_dir/oab-java.sh",
        timeout => 300,
        creates => '/usr/lib/jvm/java-6-sun/jre/bin/java',
        require => File['oab-java.sh'],
    }

    package { 'sun-java6-jre':
        ensure  => installed,
        require => Exec['oab-java.sh'],
    }
}