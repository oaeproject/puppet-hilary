class oaeservice::mq {
  require oaeservice::deps::common
  require oaeservice::deps::package::java6
  require oaeservice::deps::package::erlang

  Class['::oaeservice::deps::common']           -> Class['::rabbitmq']
  Class['::oaeservice::deps::package::java6']   -> Class['::rabbitmq']
  Class['::oaeservice::deps::package::erlang']  -> Class['::rabbitmq']

  class { '::rabbitmq': }
}