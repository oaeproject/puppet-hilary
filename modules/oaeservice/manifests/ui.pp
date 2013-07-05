class oaeservice::ui {
  require ::oaeservice::deps::common
  require oaeservice::deps::package::git
  require oaeservice::deps::ppa::oae

  Class['::oaeservice::deps::common']                   -> Class['::ui']
  Class['::oaeservice::deps::package::git']             -> Class['::ui']
  Class['::oaeservice::deps::ppa::oae']                 -> Class['::ui']

  # Apply the UI class.
  class { '::ui':
    root_dir              => hiera('ux_root_dir'),
    install_method        => hiera('ux_install_method'),
    git_source            => hiera('ux_git_source'),
    git_revision          => hiera('ux_git_revision'),
    apt_package_version   => hiera('ux_apt_package_version')
  }
}