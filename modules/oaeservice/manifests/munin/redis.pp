class oaeservice::munin::redis {

  # Munin needs to be installed before this class can be applied
  require '::oaeservice::munin::client'

  # Install the redis gem.
  package { 'redis':
    ensure   => 'installed',
    provider => 'gem',
  }

  # Copy the plugins to the right place.
  file { '/etc/munin/plugins/redis_memory':
    ensure  => present,
    content => template('munin/plugins/redis/redis_memory'),
    mode    => 1777,
  }
  file { '/etc/munin/plugins/redis_commands':
    ensure  => present,
    content => template('munin/plugins/redis/redis_commands'),
    mode    => 1777,
  }
  file { '/etc/munin/plugins/redis_keys':
    ensure  => present,
    content => template('munin/plugins/redis/redis_keys'),
    mode    => 1777,
  }
  file { '/etc/munin/plugins/redis_latency':
    ensure  => present,
    content => template('munin/plugins/redis/redis_latency'),
    mode    => 1777,
  }
}