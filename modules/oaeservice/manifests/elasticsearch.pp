class oaeservice::elasticsearch {
  include oaeservice::deps::package::java6

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
    host_address      => $search_hosts[$index]['host'],
    host_port         => $search_hosts[$index]['port'],
    max_memory_mb     => hiera('search_memory_mb'),
    min_memory_mb     => hiera('search_memory_mb'),
    path_data         => hiera('search_data_dir'),
    version           => hiera('search_version'),
    rsyslog_enabled   => $rsyslog_enabled,
    rsyslog_host      => $rsyslog_host,
    require           => [ Class['::Oaeservice::Deps::Package::Java6'] ],
  }
}