class oaeservice::munin::rabbitmq {

  # Munin needs to be installed before this class can be applied
  Class['munin::client'] -> Class['oaeservice::munin::rabbitmq']

  # Copy the plugins to the right place.
  file { '/etc/munin/plugins/rabbitmq_connections':
    ensure  => present,
    content => template('munin/plugins/rabbitmq/rabbitmq_connections'),
    mode    => 0777,
  }

  file { '/etc/munin/plugins/rabbitmq_consumers':
    ensure  => present,
    content => template('munin/plugins/rabbitmq/rabbitmq_consumers'),
    mode    => 0777,
  }
  file { '/etc/munin/plugins/rabbitmq_messages':
    ensure  => present,
    content => template('munin/plugins/rabbitmq/rabbitmq_messages'),
    mode    => 0777,
  }
  file { '/etc/munin/plugins/rabbitmq_messages_unacknowledged':
    ensure  => present,
    content => template('munin/plugins/rabbitmq/rabbitmq_messages_unacknowledged'),
    mode    => 0777,
  }
  file { '/etc/munin/plugins/rabbitmq_messages_uncommitted':
    ensure  => present,
    content => template('munin/plugins/rabbitmq/rabbitmq_messages_uncommitted'),
    mode    => 0777,
  }
  file { '/etc/munin/plugins/rabbitmq_queue_memory':
    ensure  => present,
    content => template('munin/plugins/rabbitmq/rabbitmq_queue_memory'),
    mode    => 0777,
  }

  # Copy the config file.
  file { '/etc/munin/plugin-conf.d/rabbitmq.conf':
    ensure  => present,
    content => template('munin/plugins/rabbitmq/rabbitmq.conf'),
    mode    => 0644,
  }
}