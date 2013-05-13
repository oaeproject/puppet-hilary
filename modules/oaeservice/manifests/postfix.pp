class oaeservice::postfix {

  $smtp_server_host = hiera('email_smtp_host')
  $smtp_server_port = hiera('email_smtp_port')
  $smtp_server_user = hiera('email_smtp_user')
  $smtp_server_pass = hiera('email_smtp_pass')
  $blacklisted_domains = hiera('email_blacklisted_domains')

  class { '::postfix':
    smtp_server_host => $smtp_server_host,
    smtp_server_port => $smtp_server_port,
    smtp_server_user => $smtp_server_user,
    smtp_server_pass => $smtp_server_pass,
    blacklisted_domains => $blacklisted_domains,
  }
}