class oaeservice::nagios::memory {

  # Make sure that the nagios service gets applied first.
  Class['::nagios::client'] -> Class['::oaeservice::nagios::memory']

  # Add the free memory command as a check to each node.
  @@nagios_service { "${hostname}_check_free_memory":
    use                 => "generic-service",
    service_description => "Memory::Free",
    host_name           => "$hostname",
    check_command       => "check_nrpe_1arg!check_free_memory",
    target              => "/etc/nagios3/conf.d/puppet/services/$hostname-check-free-memory.cfg",
  }
}
