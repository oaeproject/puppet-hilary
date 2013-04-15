class haproxy::service ($enabled) {
    
    $content = $enabled ? { true => '1', false => '0' } 

    file { '/etc/default/haproxy':
        content => "ENABLED=${content}",
        notify => Service['haproxy']
    }

    service { 'haproxy': ensure => running, require => File['/etc/default/haproxy'] }
}