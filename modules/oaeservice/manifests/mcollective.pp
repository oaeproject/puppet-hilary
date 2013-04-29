class oaeservice::mcollective (
        $mco_version,
        $mco_puppet_version,
        $mco_package_version,
        $mco_service_version) {

    package { "mcollective": ensure => $mco_version, alias => 'mcollective' }

    package { "mcollective-puppet-agent":
        ensure  => $mco_puppet_version,
        require => Package['mcollective'],
        before  => Service['mcollective'],
        notify => Service['mcollective'],
    }

    package { "mcollective-package-agent":
        ensure  => $mco_package_version,
        require => Package['mcollective'],
        before  => Service['mcollective'],
        notify => Service['mcollective'],
    }

    package { "mcollective-service-agent":
        ensure  => $mco_service_version,
        require => Package['mcollective'],
        before  => Service['mcollective'],
        notify => Service['mcollective'],
    }

    service { 'mcollective':
        ensure  => running,
        require => Package['mcollective']
    }
}