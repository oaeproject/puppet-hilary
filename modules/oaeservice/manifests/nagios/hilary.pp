class oaeservice::nagios::hilary {

  # Make sure that the nagios service gets applied first.
  Class['::nagios::client'] -> Class['::oaeservice::nagios::hilary']

  @@nagios_service { "${hostname}_check_app_running":
    use                 => "generic-service",
    service_description => "Hilary::Running",
    host_name           => "$hostname",
    check_command       => "check_nrpe_1arg!check_hilary_running",
    target              => "/etc/nagios3/conf.d/puppet/services/$hostname-check-hilary-running.cfg",
  }

  @@nagios_service { "${hostname}_check_hilary_http_admin":
    use                 => "generic-service",
    service_description => "Hilary::HTTP::Admin",
    host_name           => "$hostname",
    check_command       => "check_nrpe_1arg!check_hilary_http_admin",
    target              => "/etc/nagios3/conf.d/puppet/services/$hostname-check-hilary-http-admin.cfg",
  }

  @@nagios_service { "${hostname}_check_hilary_http_tenant":
    use                 => "generic-service",
    service_description => "Hilary::HTTP::Tenant",
    host_name           => "$hostname",
    check_command       => "check_nrpe_1arg!check_hilary_http_tenant",
    target              => "/etc/nagios3/conf.d/puppet/services/$hostname-check-hilary-http-tenant.cfg",
  }

}
