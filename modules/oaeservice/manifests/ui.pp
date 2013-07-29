class oaeservice::ui {
    include ::oaeservice::deps::common
    include ::oaeservice::deps::package::git
    include ::oaeservice::deps::ppa::oae

    Class['::oaeservice::deps::common']         -> Class['::ui']
    Class['::oaeservice::deps::package::git']   -> Class['::ui']
    Class['::oaeservice::deps::ppa::oae']       -> Class['::ui']

    # Apply the UI class.
    class { '::ui':
        root_dir        => hiera('ux_root_dir'),
        install_method  => hiera('ux_install_method', 'git'),
        install_config  => hiera('ux_install_config', {'source' => 'https://github.com/oaeproject/3akai-ux', 'revision' => 'master'})
    }
}