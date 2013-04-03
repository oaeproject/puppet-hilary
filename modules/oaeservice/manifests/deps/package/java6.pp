class oaeservice::deps::package::java6 {
    case $operatingsystem {
        ubuntu, debian: {
            package { 'openjdk-6-jdk': ensure => installed }
        }
        solaris, Solaris {
            exec { "java_notsupported": command   => fail("No Java support yet for ${::operatingsystem}") }
        }
        default: {
            package { 'java-1.6.0-openjdk-devel': ensure => installed }
        }
    }
}