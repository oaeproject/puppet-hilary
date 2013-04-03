class oaeservice::mq {
  include oaeservice::deps::common
  include oaeservice::deps::package::java6
  include oaeservice::deps::package::erlang

  class { 'rabbitmq':
    require => [ Class['::Oaeservice::Deps::Common'], Class['::Oaeservice::Deps::Package::Java'],
        Class['::Oaeservice::Deps::Package::Erlang'] ],
  }
}