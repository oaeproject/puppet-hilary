class oaeservice::ui {
  include ::oaeservice::deps::common

  # TODO: This can probably be pushed down to a low-level module which handles distinction between a tarball
  # deployment and a git deployment

  $ux_root_dir = hiera('ux_root_dir')
  $ux_git_user = hiera('ux_git_user')
  $ux_git_branch = hiera('ux_git_branch')

  # git clone http://github.com/sakaiproject/3akai-ux
  vcsrepo { $ux_root_dir:
    ensure    => latest,
    provider  => git,
    source    => "http://github.com/${ux_git_user}/3akai-ux",
    revision  => $ux_git_branch,
    require   => Class['::Oaeservice::Deps::Common'],
  }
}