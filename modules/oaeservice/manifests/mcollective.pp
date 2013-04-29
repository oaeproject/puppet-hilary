class oaeservice::mcollective (
        $mco_version,
        $mco_puppet_version,
        $mco_package_version,
        $mco_service_version) {

    package { "mcollective=${mco_version}": ensure => installed, alias => 'mcollective' }

    package { "mcollective-puppet-agent=${mco_puppet_version}":
        ensure  => installed,
        require => Package['mcollective'],
        before  => Service['mcollective'],
    }
    package { "mcollective-package-agent=${mco_package_version}":
        ensure  => installed,
        require => Package['mcollective'],
        before  => Service['mcollective'],
    }

    package { "mcollective-service-agent=${mco_service_version}":
        ensure  => installed,
        require => Package['mcollective'],
        before  => Service['mcollective'],
    }

    service { 'mcollective':
        ensure  => running,
        require => Package['mcollective']
    }
}