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

  # We can't use the default check_nrpe,
  # as that will execute the command on the search node.
  # Instead, we connect to the syslog server and execute the command there.
  #@@nagios_command { 'check_nrpe_syslog_1arg':
  #  target              => '/etc/nagios3/conf.d/puppet/commands/check_nrpe_syslog_1arg.cfg',
  #  command_line        => "/usr/lib/nagios/plugins/check_nrpe -H syslog -c \$ARG1\$ -a \$ARG2\$",
  #  ensure              => 'present',
  #}

#  @@nagios_service { "${hostname}_check_elasticsearch_slow_query":
#    use                 => "generic-service",
#    service_description => "Elastichsearch::Slow::Query",
#    host_name           => "$hostname",
#    check_command       => "check_nrpe_syslog_1arg!check_elasticsearch_slow!${hostname},${ipaddress_eth1},query",
#    target              => "/etc/nagios3/conf.d/puppet/services/$hostname-check-elasticsearch-slow-query.cfg",
#  }

#  @@nagios_service { "${hostname}_check_elasticsearch_slow_index":
#    use                 => "generic-service",
#    service_description => "Elastichsearch::Slow::Index",
#    host_name           => "$hostname",
#    check_command       => "check_nrpe_syslog_1arg!check_elasticsearch_slow!${hostname},${ipaddress_eth1},index",
#    target              => "/etc/nagios3/conf.d/puppet/services/$hostname-check-elasticsearch-slow-index.cfg",
#  }

#  @@nagios_service { "${hostname}_check_elasticsearch_slow_index_merge":
#    use                 => "generic-service",
#    service_description => "Elastichsearch::Slow::Index Merge",
#    host_name           => "$hostname",
#    check_command       => "check_nrpe_syslog_1arg!check_elasticsearch_slow!${hostname},${ipaddress_eth1},index_merge",
#    target              => "/etc/nagios3/conf.d/puppet/services/$hostname-check-elasticsearch-slow-index-merge.cfg",
#  }

  @@nagios_service { "${hostname}_check_elasticsearch_jvm":
    use                 => "generic-service",
    service_description => "Elastichsearch::JVM",
    host_name           => "$hostname",
    check_command       => "check_nrpe!check_elasticsearch_jvm!${ipaddress_eth1} ${hostname}",
    target              => "/etc/nagios3/conf.d/puppet/services/$hostname-check-elasticsearch-jvm.cfg",
  }
}
