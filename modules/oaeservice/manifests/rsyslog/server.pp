class oaeservice::rsyslog::server {
  class { '::rsyslog': clientOrServer  => 'server' }
}