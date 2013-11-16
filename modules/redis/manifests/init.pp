class redis (
    $version,
    $checksums,
    $owner                = 'root',
    $group                = 'root',
    $eviction_maxmemory   = false,
    $eviction_policy      = false,
    $eviction_samples     = false,
    $working_dir          = '/var/run/redis',
    $db_filename          = 'dump.rdb',
    $slave_of             = false,
    $syslog_enabled       = false,) {

  $redis_tools_filename = "redis-tools_${version}_amd64.deb"
  $redis_server_filename = "redis-server_${version}_amd64.deb"

  # Download the Redis deb files
  archive::download { $redis_tools_filename:
    url           => "http://ftp.us.debian.org/debian/pool/main/r/redis/${redis_tools_filename}",
    digest_string => $checksums['redis-tools'],
    digest_type   => 'md5',
    src_target    => '/usr/src',
  }

  archive::download { $redis_server_filename:
    url           => "http://ftp.us.debian.org/debian/pool/main/r/redis/${redis_server_filename}",
    digest_string => $checksums['redis-server'],
    digest_type   => 'md5',
    src_target    => '/usr/src',
  }

  package { 'libjemalloc1': ensure => 'installed' }

  package { 'redis-tools':
    ensure    => installed,
    provider  => dpkg,
    source    => "/usr/src/${redis_tools_filename}",
    require   => [
      Archive::Download[$redis_tools_filename],
      Package['libjemalloc1'],
    ],
  }

  package { 'redis-server':
    ensure    => installed,
    provider  => dpkg,
    source    => "/usr/src/${redis_server_filename}",
    require   => [
      Archive::Download[$redis_server_filename],
      Package['libjemalloc1', 'redis-tools'],
    ],
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
