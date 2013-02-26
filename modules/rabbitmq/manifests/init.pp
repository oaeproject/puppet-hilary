class rabbitmq {

  ##########################
  ## PACKAGE DEPENDENCIES ##
  ##########################

  package { 'java-1.6.0-openjdk-devel':
    ensure  => installed,
  }

  package { 'erlang':
    ensure  => installed,
  }

  package { 'rabbitmq-server':
    ensure  => installed,
  }

  service { 'rabbitmq-server':
    ensure  => running,
  }
  
}