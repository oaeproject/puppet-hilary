class oaeservice::elasticsearch {
  $search_hosts = hiera('search_hosts')
  $index = hiera('nodesuffix')
  
  $rsyslog_enabled = hiera('rsyslog_enabled', false)
  if $rsyslog_enabled {
    $rsyslog_host = hiera('rsyslog_host')
  } else {
    $rsyslog_host = false
  }

  class { '::elasticsearch':
    search_hosts      => $search_hosts,
    host_address      => $search_hosts[$index],
    host_port         => hiera('search_port', 9200),
    max_memory_mb     => hiera('search_memory_mb'),
    min_memory_mb     => hiera('search_memory_mb'),
    version           => hiera('search_version'),
    rsyslog_enabled   => $rsyslog_enabled,
    rsyslog_host      => $rsyslog_host,
  }
}