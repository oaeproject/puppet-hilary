# == Class: etherpad::install::apt
#
# This class is responsible for deploying the Etherpad files via the apt package manager
#
# === Parameters
#
# [*package_version*]
#   This should be the version of the Etherpad package you wish to deploy.
class etherpad::install::apt (
        $package_version
    ) {

    package { 'etherpad-lite':
        ensure => $package_version,
    }
}
