# == Class: hilary::install::apt
#
# This class is responsible for deploying the Hilary files via the apt package manager
#
# === Parameters
#
# [*package_version*]
#   This should be the version of the Hilary package you wish to deploy.
class hilary::install::apt (
        $package_version
    ) {

    package { 'hilary':
        ensure => $package_version,
    }
}
