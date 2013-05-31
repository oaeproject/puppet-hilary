class oaeservice::nagios::server {

  # The nagios server
  class { '::nagios::server':
    http_username         => hiera('nagios_http_username'),
    http_password         => hiera('nagios_http_password'),
    enable_notifications  => hiera('nagios_enable_notifications'),
  }
}
