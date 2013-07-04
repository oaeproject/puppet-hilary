class oaeservice::mq {
  require oaeservice::deps::ppa::oae
  require oaeservice::deps::common
  require oaeservice::deps::package::erlang

  Class['::oaeservice::deps::common']           -> Class['::rabbitmq::server']
  Class['::oaeservice::deps::package::erlang']  -> Class['::rabbitmq::server']

  class { '::rabbitmq::server':
    config_cluster      => true,
    cluster_disk_nodes  => hiera('mq_hosts'),
    notify              => Exec['enable_management_plugin']
  }

  # Enable the rabbitmq_management plugin for monitoring
  exec { 'enable_management_plugin':
    command => 'rabbitmq-plugins enable rabbitmq_management',
    require => Class['::rabbitmq::server'],
  }
}