class oaeservice::nagios::proxy {

    # Make sure that the nagios service gets applied first
    Class['::nagios::client'] -> Class['::oaeservice::nagios::proxy']


    @@nagios_service { "${hostname}_check_haproxy_running":
        use                 => "generic-service",
        service_description => "HAProxy::Running",
        host_name           => "$hostname",
        check_command       => "check_nrpe_1arg!check_haproxy_running",
        target              => "/etc/nagios3/conf.d/puppet/services/$hostname-check-haproxy-running.cfg",
    }

    @@nagios_service { "${hostname}_check_redis_cache_port":
        use                 => "generic-service",
        service_description => "Redis::Cache::Alive",
        host_name           => "$hostname",
        check_command       => "check_nrpe!check_redis_port!6379",
        target              => "/etc/nagios3/conf.d/puppet/services/$hostname-check-redis-cache-port.cfg",
    }

    @@nagios_service { "${hostname}_check_redis_activity_cache_port":
        use                 => "generic-service",
        service_description => "Redis::ActivityCache::Alive",
        host_name           => "$hostname",
        check_command       => "check_nrpe!check_redis_port!6380",
        target              => "/etc/nagios3/conf.d/puppet/services/$hostname-check-redis-activity-cache-port.cfg",
    }
}
