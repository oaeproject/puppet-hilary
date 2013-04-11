class redis (
    $owner                = 'root',
    $group                = 'root',
    $eviction_maxmemory   = false,
    $eviction_policy      = false,
    $eviction_samples     = false,
    $slave_of             = false,
    $syslog_enabled       = false,) {

  include apt
  apt::source { 'dotdeb':
    location    => 'http://packages.dotdeb.org',
    repos       => 'stable all',
    release     => '',
    key         => '89DF5277',
    key_source  => 'http://www.dotdeb.org/dotdeb.gpg',
    include_src => false,
  }

  package { 'redis-server': ensure => installed, require => Class['apt'] }


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
