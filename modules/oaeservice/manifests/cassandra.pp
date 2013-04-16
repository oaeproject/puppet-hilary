class oaeservice::cassandra {
  require oaeservice::deps::package::java6

  Class['::oaeservice::deps::package::java6']   -> Class['::cassandra']

  $hosts = map_hieraptr('db_hosts')
  $tokens = hiera('db_tokens')
  $index = hiera('db_index', 0)

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
    cassandra_data_dir  => hiera('db_data_dir'),
    hosts               => $hosts,
    listen_address      => $hosts[$index],
    initial_token       => $tokens[$index],
    rsyslog_enabled     => $rsyslog_enabled,
    rsyslog_host        => $rsyslog_host
  }
}