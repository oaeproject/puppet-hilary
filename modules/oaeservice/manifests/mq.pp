class oaeservice::mq {
  require oaeservice::deps::common
  require oaeservice::deps::package::java6
  require oaeservice::deps::package::erlang

  Class['::oaeservice::deps::common']           -> Class['::rabbitmq::server']
  Class['::oaeservice::deps::package::java6']   -> Class['::rabbitmq::server']
  Class['::oaeservice::deps::package::erlang']  -> Class['::rabbitmq::server']

  class { '::rabbitmq::repo::apt': pin => 900 }

  class { '::rabbitmq::server':
    config_cluster      => true,
    cluster_disk_nodes  => map_hieraptr('mq_hosts'),
    require             => Class['::rabbitmq::repo::apt'],
  }
}