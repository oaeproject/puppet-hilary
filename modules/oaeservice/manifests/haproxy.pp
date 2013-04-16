class oaeservice::haproxy {
    
    if (hiera('rsyslog_enabled', false)) {
        $syslog_ip = hieraptr('rsyslog_host')
    } else {
        $syslog_ip = '127.0.0.1'
    }

    $host_name = $::certname

    $cache_master = hieraptr('ip_cache_master')
    $cache_slave = hieraptr('ip_cache_slave')
    $cache_port = hiera('cache_port')

    $activity_cache_enabled = hiera('activitycache_enabled', false)
    $activity_cache_master = hieraptr('activitycache_master', false)
    $activity_cache_slave = hieraptr('activitycache_slave', false)
    $activity_cache_port = hiera('activitycache_port', false)

    class { '::haproxy': }
}