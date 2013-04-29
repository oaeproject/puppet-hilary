class oaeservice::mq {
  require oaeservice::deps::common
  require oaeservice::deps::package::java6
  require oaeservice::deps::package::erlang

  Class['::oaeservice::deps::common']           -> Class['::rabbitmq::server']
  Class['::oaeservice::deps::package::java6']   -> Class['::rabbitmq::server']
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
    command => '/usr/lib/rabbitmq/lib/rabbitmq_server-2.7.1/sbin/rabbitmq-plugins enable rabbitmq_management',
    notify  => Class['::rabbitmq::service'],
    require => Class['::rabbitmq::server'],
  }
}