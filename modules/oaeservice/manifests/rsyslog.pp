class oaeservice::rsyslog {
  class { '::rsyslog': server_host => hiera('rsyslog_host') }
}