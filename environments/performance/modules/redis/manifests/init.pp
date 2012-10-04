class redis {

  package { 'redis':
    ensure => present,
    provider  => pkgin,
  }

  # define the service to restart
  service { "redis":
    ensure  => 'running',
    enable  => "true",
    require => Package['redis'],
  }
  
}