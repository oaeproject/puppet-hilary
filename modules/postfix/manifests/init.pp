class postfix (
    $smtp_server_host,
    $smtp_server_port,
    $smtp_server_user,
    $smtp_server_pass,
    $blacklisted_domains = ['example.com', 'localhost', '127.0.0.1']
){

    package { 'postfix':
        ensure => present,
    }

    # Make sure postfix is sending out mails via the correct SMTP relay.
    file { '/etc/postfix/main.cf':
        ensure  => present,
        content => template('postfix/main.cf.erb'),
        require => Package['postfix'],
    }

    # Configure our blackhole domains
    file { '/etc/aliases':
        ensure  => present,
        content => template('postfix/aliases.erb'),
        notify  => Exec['newaliases'],
        require => Package['postfix'],
    }
    exec { 'newaliases':
        require => File['/etc/aliases'],
    }

    # Configure postfix to pick up the virtual aliases
    file { '/etc/postfix/virtual_alias':
        ensure  => present,
        content => template('postfix/virtual_alias.erb'),
        require => [ Exec['newaliases'], Package['postfix'] ],
    }
    exec { 'postmap /etc/postfix/virtual_alias':
        require => File['/etc/postfix/virtual_alias'],
    }


    service { 'postfix':
        ensure  => running,
        require => [ File['/etc/postfix/main.cf'], Exec['newaliases'], Exec['postmap /etc/postfix/virtual_alias'] ]
    }
}
