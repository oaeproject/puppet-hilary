# == Class: ui
#
# This class is responsible for deploying the UI files in the correct location.
#
# === Parameters
#
# [*root_dir*]
#   The directory where the UI files should be put.
#   Defaults to /opt/3akai-ux
#
# [*install_method*]
#   Whether to use git or the Ubuntu package to install.
#   Options: `git` or `package`.
#
# [*git_source*]
#   The full git url to pull the sources from.
#   ex: https://github.com/oaeproject/3akai-ux
#
# [*git_revision*]
#   Which branch, tag or commit to pull.
#
# [*apt_package_version*]
#   In case you're deploying the UI via a package, this should be the version of the package you wish to deploy.
class ui (
        $root_dir               = '/opt/3akai-ux',
        $install_method         = 'git',
        $git_source             = 'oaeproject',
        $git_revision           = 'master',
        $apt_package_version    = '0.2.0-2'
    ){

    case $app_install_method {
        'git': {
            vcsrepo { $root_dir:
                ensure    => latest,
                provider  => git,
                source    => $git_source,
                revision  => $git_revision,
            }
        }
        'package': {
            package { '3akai-ux':
                ensure => $apt_package_version,
            }
        }
        default: {
            warning("Unknown install method for the ui class passed in: '${install_method}'")
        }
    }
}
