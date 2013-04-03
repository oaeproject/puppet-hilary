class oaeservice::cassandra {
  require oaeservice::deps::package::java6

  Class['::oaeservice::deps::package::java6']   -> Class['::cassandra']

  $hosts = hiera('db_hosts')
  $tokens = hiera('db_tokens')
  $suffix = hiera('nodesuffix')

  case $suffix {
    undef, false, '': {
      $index = 0
    }
    default: {
      $index = $suffix
    }
  }

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
    rsyslog_host        => $rsyslog_host
  }
}