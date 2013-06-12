class dse::opscenter ($version = '3.1.1', $listen_interface = '0.0.0.0', $listen_port = 8888) {

    # Install the DSE apt repository
    require dse::apt

    package { 'libssl0.9.8': ensure => installed }
    package { 'opscenter': ensure => $version }

    file { 'opscenterd.conf':
        path    => '/etc/opscenter/opscenterd.conf',
        mode    => 0444,
        content => template('dse/opscenterd.conf.erb')
    }

    service { 'opscenterd':
        ensure      => 'running',
        subscribe   => File['opscenterd.conf'],
        require     => File['opscenterd.conf'],
    }
}