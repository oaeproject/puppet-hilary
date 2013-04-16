class oaeservice::nagios {

  class {'::nagios::client':
    hostgroup => hiera('nagios_hostgroup')
  }
}
