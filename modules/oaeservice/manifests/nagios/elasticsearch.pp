class oaeservice::nagios::elasticsearch {

  # Make sure that the nagios service gets applied first.
  Class['::nagios::client'] -> Class['::oaeservice::nagios::elasticsearch']

  @@nagios_service { "${hostname}_check_elasticsearch_running":
    use                 => "generic-service",
    service_description => "Elasticsearch::Running",
    host_name           => "$hostname",
    check_command       => "check_nrpe_1arg!check_elasticsearch_running",
    target              => "/etc/nagios3/conf.d/puppet/services/$hostname-check-elasticsearch-running.cfg",
  }

  @@nagios_service { "${hostname}_check_elasticsearch_health":
    use                 => "generic-service",
    service_description => "Elastichsearch::Health",
    host_name           => "$hostname",
    check_command       => "check_nrpe_1arg!check_elasticsearch_health",
    target              => "/etc/nagios3/conf.d/puppet/services/$hostname-check-elasticsearch-health.cfg",
  }

  @@nagios_service { "${hostname}_check_elasticsearch_jvm":
    use                 => "generic-service",
    service_description => "Elastichsearch::JVM",
    host_name           => "$hostname",
    check_command       => "check_nrpe!check_elasticsearch_jvm!${ipaddress_eth1} ${hostname}",
    target              => "/etc/nagios3/conf.d/puppet/services/$hostname-check-elasticsearch-jvm.cfg",
  }
}
