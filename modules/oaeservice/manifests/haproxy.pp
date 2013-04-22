class oaeservice::haproxy {
    
    if (hiera('rsyslog_enabled', false)) {
        $syslog_ip = hiera('rsyslog_host')
    } else {
        $syslog_ip = '127.0.0.1'
    }

    $host_name = $::certname

    $cache_master = hiera('cache-master')
    $cache_slave = hiera('cache-slave')
    $cache_port = hiera('cache_port')

    $activity_cache_enabled = hiera('activitycache_enabled', false)
    $activity_cache_master = hiera('activity-cache-master', false)
    $activity_cache_slave = hiera('activity-cache-slave', false)
    $activity_cache_port = hiera('activitycache_port', false)

    class { '::haproxy': }
}