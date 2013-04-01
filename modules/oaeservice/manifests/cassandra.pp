class oaeservice::cassandra {

  $hosts = hiera('db_hosts')
  $tokens = hiera('db_tokens')
  $index = hiera('nodesuffix')

  class { '::cassandra':
    owner               => hiera('db_os_user'),
    group               => hiera('db_os_group'),
    cluster_name        => hiera('db_cluster_name'),
    hosts               => $hosts,
    listen_address      => $hosts[$index],
    initial_token       => $tokens[$index],
    rsyslog_enabled     => hiera('rsyslog_enabled', false),
    rsyslog_host        => hiera('rsyslog_hosts'),
  }
}