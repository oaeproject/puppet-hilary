class oaeservice::nagios::preview_runtime {

  # Make sure nagios service gets applied first
  Class['::nagios::client'] -> Class['::oaeservice::nagios::preview_runtime']

  @@nagios_service { "${hostname}_check_preview_runtime":
    use                 => "generic-service",
    service_description => "Preview::Runtime",
    host_name           => "$hostname",
    check_command       => "check_nrpe_1arg!check_preview_runtime",
    target              => "/etc/nagios3/conf.d/puppet/services/$hostname-check-preview-runtime.cfg",
  }

}

