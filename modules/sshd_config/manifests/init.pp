class sshd_config {

  file { "/etc/ssh/sshd_config":
    notify  => Service['ssh'],
    content => template("sshd_config/sshd_config.erb"),
  }

  service { 'ssh': ensure  => running }

}