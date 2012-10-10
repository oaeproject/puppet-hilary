class opscenter(
    $listen_address = '0.0.0.0',
    $port = 8888) {

  package { 'opscenter-free':
    ensure  => installed,
  }
  
  file { '/etc/opscenter/opscenterd.conf':
    ensure  => present,
    content => template('opscenter/opscenterd.conf.erb'),
    require => Package['opscenter-free'],
    notify  => Service['opscenterd'],
  }
  
  service { 'opscenterd':
    ensure  => 'running',
    enable  => 'true',
    require => Package['opscenter-free'],
  }

  # Make a call to the opscenter API to register our Cassandra cluster.
  # This can only be run when the entire cluster is up and running.
  #exec { 'register_cluster':
  #  require => Service['opscenterd'],
  #  command => '/usr/bin/curl -d \'{"jmx": {"username": "", "password": "", "port": "7199"}, "cassandra": {"username": "", "seed_hosts": "$localconfig::db_hosts[0], $localconfig::db_hosts[1], $localconfig::db_hosts[2]", "api_port": "9160", "password": ""}}\' -X POST http://127.0.0.1:8888/cluster-configs',
  #}
  
}