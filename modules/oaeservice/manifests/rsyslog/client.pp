class oaeservice::rsyslog::client {
  class { '::rsyslog':
    clientOrServer  => 'client',
    server_host     => hieraptr('rsyslog_host'),
  }
}