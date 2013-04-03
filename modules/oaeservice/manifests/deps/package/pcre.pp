class oaeservice::deps::package::pcre {
    case $operatingsystem {
        debian, ubuntu: {
            package { 'libpcre3': ensure => installed }
            package { 'libpcre3-dev': ensure => installed }
        }
    }
}