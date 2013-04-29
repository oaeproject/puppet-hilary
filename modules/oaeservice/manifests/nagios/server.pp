class oaeservice::nagios::server {

  # The nagios server
  class { '::nagios::server':
    http_username         => hiera('nagios_http_username'),
    http_password         => hiera('nagios_http_password'),
    enable_notifications  => hiera('nagios_enable_notifications'),
    smtp_server_host      => hiera('nagios_smtp_host'),
    smtp_server_port      => hiera('nagios_smtp_port'),
    smtp_server_user      => hiera('nagios_smtp_user'),
    smtp_server_pass      => hiera('nagios_smtp_pass'),
    email_address         => hiera('nagios_email_address'),
  }

}