define redis (
    $eviction_maxmemory   = false,
    $eviction_policy      = false,
    $eviction_samples     = false,
    $slave_of             = false,
    $syslog_enabled       = false,) {

  package { 'redis':
    ensure    => present,
    provider  => pkgin,
  }

  exec { 'svccfg import redis.xml':
    command => '/usr/sbin/svccfg import /opt/local/share/smf/redis/manifest.xml',
    require => Package['redis'],
  }

  # Set the configuration file.
  file { 'redis.conf':
    path    => '/opt/local/etc/redis.conf',
    ensure  => present,
    mode    => 0644,
    owner   => $owner,
    group   => $group,
    content => template('redis/redis.conf.erb'),
    require => Package['redis']
  }

  # define the service to restart
  service { 'redis':
    ensure    => 'running',
    enable    => 'true',
    require   => [ File['redis.conf'] ],
  }

}
