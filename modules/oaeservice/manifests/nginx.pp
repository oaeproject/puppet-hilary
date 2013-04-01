class oaeservice::nginx {
  
  package { 'gcc47':    ensure => present, provider => pkgin }
  package { 'gmake':    ensure => present, provider => pkgin }
  package { 'automake': ensure => present, provider => pkgin }
  package { 'nodejs':   ensure => present, provider => pkgin }
  package { 'scmgit':   ensure => present, provider => pkgin }

  $ux_root = hiera('ux_root_dir')
  $ux_git_user = hiera('ux_git_user')
  $ux_git_branch = hiera('ux_git_branch')

  # git clone http://github.com/sakaiproject/3akai-ux
  vcsrepo { $ux_root:
    ensure    => latest,
    provider  => git,
    source    => "http://github.com/${ux_git_user}/3akai-ux",
    revision  => $ux_git_branch,
    require   => Package['scmgit'],
  }

  class { '::nginx':
    internal_app_ips      => hiera('app_hosts'),
    internal_etherpad_ips => hiera('etherpad_hosts'),
    ux_home               => $ux_root,
    ux_admin_host         => hiera('app_admin_host'),
    files_home            => hiera('app_files_dir'),
  }
}