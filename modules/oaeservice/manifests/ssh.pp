class oaeservice::ssh {
    
    file { '/etc/ssh/sshd_config':
        ensure  => file,
        content => template('oaeservice/sshd/sshd_config_default.erb'),
    }

    service { 'ssh': ensure => running }
}