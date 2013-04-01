class oaeservice::cassandra {

  $hosts = hiera('db_hosts')
  $tokens = hiera('db_tokens')
  $index = hiera('nodesuffix')

  $rsyslog_enabled = hiera('rsyslog_enabled', false)
  if $rsyslog_enabled {
    $rsyslog_host = hiera('rsyslog_host')
  } else {
    $rsyslog_host = false
  }

  class { '::cassandra':
    owner               => hiera('db_os_user'),
    group               => hiera('db_os_group'),
    cluster_name        => hiera('db_cluster_name'),
    hosts               => $hosts,
    listen_address      => $hosts[$index],
    initial_token       => $tokens[$index],
    rsyslog_enabled     => $rsyslog_enabled,
    rsyslog_host        => $rsyslog_host,
  }
}