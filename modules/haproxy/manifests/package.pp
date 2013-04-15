class haproxy::package ($version) {
    package { "haproxy=${version}": ensure => installed }
}