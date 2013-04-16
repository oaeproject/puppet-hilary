class oaeservice::nagios::cassandra {

  # Make sure that the nagios service gets applied first.
  Class['::nagios::client'] -> Class['::oaeservice::nagios::cassandra']

  # Add a check to query against cassandra
  @@nagios_service { "${hostname}_check_cassandra_query":
    use                 => "generic-service",
    service_description => "Cassandra::Query",
    host_name           => "$hostname",
    check_command       => "check_nrpe_1arg!check_cassandra_query",
    target              => "/etc/nagios3/conf.d/puppet/services/$hostname-check-cassandra-query.cfg",
  }

  @@nagios_service { "${hostname}_check_cassandra_running":
    use                 => "generic-service",
    service_description => "Cassandra::Running",
    host_name           => "$hostname",
    check_command       => "check_nrpe_1arg!check_cassandra_running",
    target              => "/etc/nagios3/conf.d/puppet/services/$hostname-check-cassandra-running.cfg",
  }
}
