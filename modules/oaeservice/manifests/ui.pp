class oaeservice::ui {
  require ::oaeservice::deps::common
  require oaeservice::deps::package::git
  require oaeservice::deps::ppa::oae

  Class['::oaeservice::deps::common']                   -> Class['::ui']
  Class['::oaeservice::deps::package::git']             -> Class['::ui']
  Class['::oaeservice::deps::ppa::oae']                 -> Class['::ui']

  # Apply the UI class.
  class { '::ui':
    root_dir         => hiera('ux_root_dir'),
    install_method   => hiera('ux_install_method'),
    git_user         => hiera('ux_git_user'),
    git_branch       => hiera('ux_git_branch'),
    package_name     => hiera('ux_package_name'),
    package_version  => hiera('ux_package_version')
  }
}