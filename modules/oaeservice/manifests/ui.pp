class oaeservice::ui {
    include ::oaeservice::deps::common
    include ::oaeservice::deps::package::git
    include ::oaeservice::deps::ppa::oae

    Class['::oaeservice::deps::common']         -> Class['::ui']
    Class['::oaeservice::deps::package::git']   -> Class['::ui']
    Class['::oaeservice::deps::ppa::oae']       -> Class['::ui']

    # Apply the UI class.
    class { '::ui':
        root_dir            => hiera('ux_root_dir'),
        install_method      => hiera('ux_install_method', 'git'),
        git_source          => hiera('ux_git_source', 'https://github.com/oaeproject/3akai-ux'),
        git_revision        => hiera('ux_git_revision', 'master'),
        apt_package_version => hiera('ux_apt_package_version', 'present'),
    }
}