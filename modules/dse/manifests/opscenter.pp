class dse::opscenter ($version = '3.2.1', $listen_interface = '0.0.0.0', $listen_port = 8888) {
    include ::dse::apt

    package { 'libssl0.9.8': ensure => installed }
    package { 'opscenter': ensure => $version, require => Package['libssl0.9.8'] }

    file { 'opscenterd.conf':
        path    => '/etc/opscenter/opscenterd.conf',
        mode    => 0444,
        content => template('dse/opscenterd.conf.erb'),
        require => Package['opscenter'],
    }

    service { 'opscenterd':
        ensure      => 'running',
        subscribe   => File['opscenterd.conf'],
        require     => File['opscenterd.conf'],
    }
}