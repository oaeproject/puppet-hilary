class oaeservice::mcollective {

    package { "mcollective": ensure => installed, alias => 'mcollective' }

    package { "mcollective-puppet-agent":
        ensure  => installed,
        require => Package['mcollective'],
        before  => Service['mcollective'],
        notify  => Service['mcollective'],
    }

    package { "mcollective-package-agent":
        ensure  => installed,
        require => Package['mcollective'],
        before  => Service['mcollective'],
        notify  => Service['mcollective'],
    }

    package { "mcollective-service-agent":
        ensure  => installed,
        require => Package['mcollective'],
        before  => Service['mcollective'],
        notify  => Service['mcollective'],
    }

    service { 'mcollective':
        ensure  => running,
        require => Package['mcollective']
    }
}