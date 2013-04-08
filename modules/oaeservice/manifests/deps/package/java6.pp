class oaeservice::deps::package::java6 {
    case $operatingsystem {
        ubuntu, debian: {
            package { 'openjdk-6-jdk': ensure => installed }
        }
        solaris, Solaris: {
            exec { 'accept_java_license': command => 'touch /opt/local/.dlj_license_accepted' }
            package { 'sun-jre6-6.0.26': ensure => installed, provider => 'pkgin', require => Exec['accept_java_license'] }
        }
        default: {
            package { 'java-1.6.0-openjdk-devel': ensure => installed }
        }
    }
}