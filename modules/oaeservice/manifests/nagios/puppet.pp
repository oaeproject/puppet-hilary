class oaeservice::nagios::puppet {

  # Make sure that the nagios service gets applied first.
  Class['::nagios::client'] -> Class['::oaeservice::nagios::puppet']


  #####################
  ## Nagios Contacts ##
  #####################

  # See http://nagios.sourceforge.net/docs/3_0/objectdefinitions.html#contact
  # Options:
  #
  # Host notifications
  #   d = notify on DOWN host states
  #   u = notify on UNREACHABLE host states
  #   r = notify on host recoveries (UP states)
  #   f = notify when the host starts and stops flapping
  #   s = send notifications when host or service scheduled downtime starts and ends.
  #   n = send no notifications to this contact
  #   
  # Service notifications
  #   w = notify on WARNING service states
  #   u = notify on UNKNOWN service states
  #   c = notify on CRITICAL service states
  #   r = notify on service recoveries (OK states)
  #   f = notify when the service starts and stops flapping
  #   n = send no notifications to this contact

  nagios_contacts = hiera('nagios_contacts', [])

  @@nagios_contact { 'oae-monitoring':
    target                        => '/etc/nagios3/conf.d/puppet/contacts/oae-monitoring.cfg',
    email                         => hiera('nagios_contact_email'),
    alias                         => hiera('nagios_contact_alias'),
    contactgroups                 => 'oae-admins',
    host_notifications_enabled    => '1',
    host_notification_period      => '24x7',
    host_notification_options     => 'd,u,r,f,s',
    host_notification_commands    => 'notify-host-by-email',
    service_notifications_enabled => '1',
    service_notification_period   => '24x7',
    service_notification_options  => 'w,u,c,r,f',
    service_notification_commands => 'notify-service-by-email',
  }

  ###################
  ## Puppet Checks ##
  ###################

  # Add a check to see if puppet ran on all nodes.
  @@nagios_service { "${hostname}_check_puppet_ran_on_all_nodes":
    use                 => "generic-service",
    service_description => "Puppet::All runs",
    host_name           => "$hostname",
    check_command       => "check_puppetmaster",
    target              => "/etc/nagios3/conf.d/puppet/services/$hostname-check-puppet-ran-on-all-nodes.cfg",
  }
}
