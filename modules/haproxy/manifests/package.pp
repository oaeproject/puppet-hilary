class haproxy::package ($version) {
    package { 'haproxy': ensure => $version }
}