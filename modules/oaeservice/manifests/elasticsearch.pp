class oaeservice::elasticsearch {

  $search_hosts = hiera('search_hosts')
  $index = hiera('search_index', 0)

  $rsyslog_enabled = hiera('rsyslog_enabled', false)
  $rsyslog_host = hiera('rsyslog_host', '127.0.0.1')

  class { '::elasticsearch':
    search_hosts      => $search_hosts,
    host_address      => $search_hosts[$index],
    heap_size_mb      => hiera('search_memory_mb'),
    heap_newsize_mb   => hiera('search_newsize_mb', null),
    path_data         => hiera('search_data_dir'),
    version           => hiera('search_version'),
    checksum          => hiera('search_checksum'),
    rsyslog_enabled   => $rsyslog_enabled,
    rsyslog_host      => $rsyslog_host,
  }
}