class oaeservice::mq {
  require oaeservice::deps::common
  require oaeservice::deps::package::java6
  require oaeservice::deps::package::erlang

  class { 'rabbitmq': }
}