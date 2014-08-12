class oaeservice::nagios::hilary_errors {

  # Make sure that the nagios service gets applied first.
  Class['::nagios::client'] -> Class['::oaeservice::nagios::hilary_errors']

  @@nagios_service { "${hostname}_check_hilary_errors":
    use                 => "generic-service",
    service_description => "Hilary::Errors",
    host_name           => "$hostname",
    check_command       => "check_nrpe_1arg!check_hilary_errors",
    target              => "/etc/nagios3/conf.d/puppet/services/$hostname-check-hilary-errors.cfg",
  }
}
