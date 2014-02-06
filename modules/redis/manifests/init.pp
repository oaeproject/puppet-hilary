class redis (
    $version,
    $owner                = 'root',
    $group                = 'root',
    $eviction_maxmemory   = false,
    $eviction_policy      = false,
    $eviction_samples     = false,
    $working_dir          = '/var/run/redis',
    $db_filename          = 'dump.rdb',
    $slave_of             = false,
    $syslog_enabled       = false,) {

  # Install redis-server from the oae PPA
  # This will include the redis tools (redis-cli, benchmark, ..) as well
  package { 'redis-server':
    ensure    => installed
  }

  # Set the configuration file
  file { 'redis.conf':
    path    => '/etc/redis/redis.conf',
    ensure  => present,
    mode    => 0644,
    owner   => $owner,
    group   => $group,
    content => template('redis/redis.conf.erb'),
    require => Package['redis-server']
  }

  # Delete any snapshots to avoid loading stale data on cache startup
  file { "${working_dir}/${db_filename}":
    ensure => absent,
  }

  # define the service to restart
  service { 'redis-server':
    ensure    => 'running',
    enable    => 'true',
    require   => File['redis.conf', "${working_dir}/${db_filename}"]
  }

}
