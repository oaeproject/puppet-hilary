class oaeservice::nagios::disk {

  # Make sure that the nagios service gets applied first.
  Class['::nagios::client'] -> Class['::oaeservice::nagios::disk']

  @@nagios_service { "${hostname}_check_disk_tmp":
    use                 => "generic-service",
    service_description => "Disk::Temp",
    host_name           => "$hostname",
    check_command       => "check_nrpe_1arg!check_disk_tmp",
    target              => "/etc/nagios3/conf.d/puppet/services/$hostname-check-disk-tmp.cfg",
  }

  @@nagios_service { "${hostname}_check_disk_data":
    use                 => "generic-service",
    service_description => "Disk::Data",
    host_name           => "$hostname",
    check_command       => "check_nrpe_1arg!check_disk_data",
    target              => "/etc/nagios3/conf.d/puppet/services/$hostname-check-disk-data.cfg",
  }
}

class oaeservice::nagios::disk::shared {

  @@nagios_service { "${hostname}_check_disk_shared":
    use                 => "generic-service",
    service_description => "Disk::Shared",
    host_name           => "$hostname",
    check_command       => "check_nrpe_1arg!check_disk_shared",
    target              => "/etc/nagios3/conf.d/puppet/services/$hostname-check-disk-shared.cfg",
  }
}