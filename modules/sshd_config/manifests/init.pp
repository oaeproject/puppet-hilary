class sshd_config {

  case $operatingsystem {
    debian, ubuntu: {
      $os = 'linux'
      $service = 'ssh'
    }
    solaris, Solaris: {
      $os = 'smartos'
      $service = 'ssh'
    }
    default: {
      $os = 'linux'
      $service = 'sshd'
    }
  }

  file { "/etc/ssh/sshd_config":
    notify  => Service["${service}"],
    content => template("sshd_config/sshd_config_${os}.erb"),
  }

  service { "${service}": ensure  => running }

}