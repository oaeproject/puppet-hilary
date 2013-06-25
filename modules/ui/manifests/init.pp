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
# [*git_user*]
#   Which Github user to pull from. It's assumed the repository name is set to 3akai-ux.
#
# [*git_branch*]
#   Which branch or tag to pull.
#
# [*package_name*]
#   In case you're deploying the UI via a package, this should be the name of the package you wish to deploy.
#
# [*package_version*]
#   In case you're deploying the UI via a package, this should be the version of the package you wish to deploy.
class ui (
        $root_dir        = '/opt/3akai-ux',
        $install_method  = 'git',
        $git_user        = 'oaeproject',
        $git_branch      = 'master',
        $package_name    = '3akai-ux',
        $package_version = '0.2.0-2'
    ){

    case $app_install_method {
        'git': {
            vcsrepo { $root_dir:
                ensure    => latest,
                provider  => git,
                source    => "https://github.com/${git_user}/3akai-ux",
                revision  => $git_branch,
            }
        }
        'package': {
            package { $package_name:
                ensure => $package_version,
            }
        }
    }
}
