define oaeadminuser ($pubkey = undef, $passwd = undef, $pubkey_type = 'ssh-rsa', $groups = 'admin') {

    user { $name:
        ensure      => 'present',
        home        => "/home/${name}",
        managehome  => true,
        password    => $passwd,
        groups      => $groups,
        shell       => '/bin/bash',
    }

    file { "/home/${name}":
        ensure  => directory,
        mode    => '0755',
        owner   => $name,
        group   => $name,
        require => User[$name],
    }

    file { "/home/${name}/.ssh":
        ensure  => directory,
        mode    => '0750',
        owner   => $name,
        group   => $name,
        require => File["/home/${name}"],
    }

    if ($pubkey) {
        ssh_authorized_key { $name:
            ensure  => 'present',
            type    => $pubkey_type,
            key     => $pubkey,
            user    => $name,
            name    => $name,
            require => File["/home/${name}/.ssh"],
        }
    }
}