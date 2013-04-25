class oaeservice::haproxy(
        $cache_primary,
        $cache_backups = false,
        $activity_cache_primary = false,
        $activity_cache_backups = false) {
    
    if (hiera('rsyslog_enabled', false)) {
        $syslog_ip = hiera('rsyslog_host')
    } else {
        $syslog_ip = '127.0.0.1'
    }

    # Managed by shared config options
    $cache_port = hiera('cache_port')
    $activity_cache_enabled = hiera('activitycache_enabled', false)
    $activity_cache_port = hiera('activitycache_port', false)

    class { '::haproxy': }
}