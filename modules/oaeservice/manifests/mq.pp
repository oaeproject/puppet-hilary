class oaeservice::mq {
  require oaeservice::deps::common
  require oaeservice::deps::package::erlang

  Class['::oaeservice::deps::common']           -> Class['::rabbitmq::server']
  Class['::oaeservice::deps::package::erlang']  -> Class['::rabbitmq::server']

  class { '::rabbitmq::repo::apt': }

  class { '::rabbitmq::server':
    config_cluster      => true,
    cluster_disk_nodes  => hiera('mq_hosts'),
    require             => Class['::rabbitmq::repo::apt'],
    notify              => Exec['enable_management_plugin']
  }

  # Enable the rabbitmq_management plugin and bounce the rabbitmq server.
  # We need the management plugin in case we want do monitoring.
  exec { 'enable_management_plugin':
    environment => 'HOME=/root',
    command     => 'rabbitmq-plugins enable rabbitmq_management',
    require     => Class['::rabbitmq::server']
  }
}