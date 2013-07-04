class redis (
    $owner                = 'root',
    $group                = 'root',
    $eviction_maxmemory   = false,
    $eviction_policy      = false,
    $eviction_samples     = false,
    $slave_of             = false,
    $syslog_enabled       = false,) {

  package { 'redis-server': ensure => installed }

  # Set the configuration file.
  file { 'redis.conf':
    path    => '/etc/redis/redis.conf',
    ensure  => present,
    mode    => 0644,
    owner   => $owner,
    group   => $group,
    content => template('redis/redis.conf.erb'),
    require => Package['redis-server']
  }

  # define the service to restart
  service { 'redis-server':
    ensure    => 'running',
    enable    => 'true',
    require   => File['redis.conf'],
  }

}
