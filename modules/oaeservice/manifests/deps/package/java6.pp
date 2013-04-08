class oaeservice::deps::package::java6 {
    case $operatingsystem {
        ubuntu, debian: {
            package { 'openjdk-6-jdk': ensure => installed }
        }
        solaris, Solaris: {
            package { 'sun-jre6-6.0.26': ensure => installed, provider => 'pkgin' }
        }
        default: {
            package { 'java-1.6.0-openjdk-devel': ensure => installed }
        }
    }
}