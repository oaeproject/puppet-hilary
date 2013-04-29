class oaeservice::nagios::nginx {

  # Make sure that the nagios service gets applied first.
  Class['::nagios::client'] -> Class['::oaeservice::nagios::nginx']

  @@nagios_service { "${hostname}_check_nginx_running":
    use                 => "generic-service",
    service_description => "Web::Nginx",
    host_name           => "$hostname",
    check_command       => "check_nrpe_1arg!check_nginx_running",
    target              => "/etc/nagios3/conf.d/puppet/services/$hostname-check-nginx-running.cfg",
  }
}
