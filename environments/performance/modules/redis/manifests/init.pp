class redis {

  package { 'redis':
    ensure    => present,
    provider  => pkgin,
  }

  # Set the configuration file.
  file { 'redis.conf':
    path => '/opt/local/etc/redis.conf',
    ensure => present,
    mode => 0640,
    owner => $owner,
    group => $group,
    content => template('redis/redis.conf.erb'),
    require => Package['redis'],
  }

  # define the service to restart
  service { 'redis':
    ensure  => 'running',
    enable  => 'true',
    require => File['redis.conf'], Package['redis'],
  }
  
}