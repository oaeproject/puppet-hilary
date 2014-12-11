class oaeservice::mq {
  include ::oaeservice::deps::ppa::oae
  include ::oaeservice::deps::common
  include ::oaeservice::deps::package::erlang

  Class['::oaeservice::deps::common']           -> Class['::rabbitmq']
  Class['::oaeservice::deps::package::erlang']  -> Class['::rabbitmq']

  class { '::rabbitmq':
    config_cluster      => true,
    cluster_nodes  => hiera('mq_hosts'),
    notify              => Exec['enable_management_plugin']
  }

  # Enable the rabbitmq_management plugin for monitoring
  exec { 'enable_management_plugin':
    command => 'rabbitmq-plugins enable rabbitmq_management',
    require => Class['::rabbitmq'],
  }
}
