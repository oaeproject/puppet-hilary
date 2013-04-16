class oaeservice::haproxy {
    
    if (hiera('rsyslog_enabled', false)) {
        $syslog_ip = hiera('rsyslog_ip')
    } else {
        $syslog_ip = undef
    }

    $host_name = $::certname
    $cache_master = hiera('cache_host_master')

}