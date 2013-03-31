class oaeservice::rsyslog::client {
  class { '::rsyslog':
    clientOrServer  => 'client',
    server_host     => hiera('rsyslog_host'),
  }
}