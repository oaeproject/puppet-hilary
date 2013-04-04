class redis (
    $owner                = 'admin',
    $group                = 'staff',
    $eviction_maxmemory   = false,
    $eviction_policy      = false,
    $eviction_samples     = false,
    $slave_of             = false,
    $syslog_enabled       = false,) {

  case $operatingsystem {
    solaris, Solaris: {
      $redis_name = 'redis'
      $redis_config_path = '/opt/local/etc/redis.conf'
      $redis_db_dir = '/var/db/redis'
      $redis_run_dir = $redis_db_dir

      package { $redis_name: ensure => present, provider => 'pkgin' }
      exec { 'svccfg import redis.xml':
        command => '/usr/sbin/svccfg import /opt/local/share/smf/redis/manifest.xml',
        require => Package['redis'],
      }
    }
    debian, ubuntu: {
      $redis_name = 'redis-server'
      $redis_config_path = '/etc/redis/redis.conf'
      $redis_db_dir = '/var/run/redis'
      $redis_run_dir = $redis_db_dir

      include apt
      apt::source { 'dotdeb':
        location    => 'http://packages.dotdeb.org',
        repos       => 'stable all',
        release     => '',
        key         => '89DF5277',
        key_source  => 'http://www.dotdeb.org/dotdeb.gpg',
        include_src => false,
      }

      package { $redis_name: ensure => installed, require => Class['apt'] }
    }
    default: {
      exec { "redis_notsupported": command => fail("Redis not supported yet for ${::operatingsystem}") }
    }
  }

  # Set the configuration file.
  file { 'redis.conf':
    path    => $redis_config_path,
    ensure  => present,
    mode    => 0644,
    owner   => $owner,
    group   => $group,
    content => template('redis/redis.conf.erb'),
    require => Package[$redis_name]
  }

  # define the service to restart
  service { $redis_name:
    ensure    => 'running',
    enable    => 'true',
    require   => File['redis.conf'],
  }

}
