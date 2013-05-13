class oaeservice::nagios::server {

  # The nagios server
  class { '::nagios::server':
    http_username         => hiera('nagios_http_username'),
    http_password         => hiera('nagios_http_password'),
    enable_notifications  => hiera('nagios_enable_notifications'),
  }

  class { '::postfix':
    smtp_server_host        => hiera('email_smtp_host'),
    smtp_server_port        => hiera('email_smtp_host'),
    smtp_server_user        => hiera('email_smtp_host'),
    smtp_server_pass        => hiera('email_smtp_host'),
    email_address           => hiera('email_smtp_host'),
    blacklisted_domains     => hiera('email_blacklisted_domains'),
  }
}
