class rabbitmq (
    $listen_address,
    $listen_port      => '5672',
    $owner            => 'rabbitmq',
    $group            => 'rabbitmq',
  ) {

  ##########################
  ## PACKAGE DEPENDENCIES ##
  ##########################

  package { 'java-1.6.0-openjdk-devel': ensure  => installed, }
  package { 'erlang': ensure  => installed, }
  package { 'rabbitmq-server': ensure  => installed, }

  file { '/etc/rabbitmq/rabbitmq.config':
    notify  => Service['rabbitmq-server'],
    ensure  => present,
    mode    => 0640,
    owner   => $owner,
    group   => $group,
    content => template('rabbitmq/rabbitmq.config.erb'),
    require => Package['rabbitmq-server'],
  }

  service { 'rabbitmq-server':
    ensure  => running,
    require => File['/etc/rabbitmq/rabbitmq.config'],
  }

}