class oaeservice::nagios::redis {

  # Make sure that the nagios service gets applied first.
  Class['::nagios::client'] -> Class['::oaeservice::nagios::redis']

  @@nagios_service { "${hostname}_check_redis_running":
    use                 => "generic-service",
    service_description => "Redis::Running",
    host_name           => "$hostname",
    check_command       => "check_nrpe_1arg!check_redis_running",
    target              => "/etc/nagios3/conf.d/puppet/services/$hostname-check-redis-running.cfg",
  }

}
