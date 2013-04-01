class oaeservice::elasticsearch {
  $search_hosts = hiera('search_hosts');
  $rsyslog_enabled = hiera('rsyslog_enabled', false)
  $index = hiera('nodesuffix')
  
  class { '::elasticsearch':
    search_hosts      => $search_hosts,
    host_address      => $search_hosts[$index],
    host_port         => hiera('search_port'),
    max_memory_mb     => hiera('search_memory_mb'),
    min_memory_mb     => hiera('search_memory_mb'),
    version           => hiera('search_version'),
    rsyslog_enabled   => $rsyslog_enabled,
    rsyslog_host      => hiera('rsyslog_host'),
  }
}