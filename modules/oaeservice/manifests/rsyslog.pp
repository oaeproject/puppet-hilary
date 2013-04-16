class oaeservice::rsyslog {
  class { '::rsyslog': server_host => hieraptr('rsyslog_host') }
}