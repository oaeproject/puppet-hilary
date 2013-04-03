class oaeservice::nginx {
  include ::oaeservice::deps::common
  
  package { 'gcc47':    ensure => present, provider => pkgin }
  package { 'gmake':    ensure => present, provider => pkgin }
  package { 'automake': ensure => present, provider => pkgin }
  package { 'nodejs':   ensure => present, provider => pkgin }
  package { 'scmgit':   ensure => present, provider => pkgin }

  class { '::nginx':
    internal_app_ips      => hiera('app_hosts'),
    internal_etherpad_ips => hiera('etherpad_hosts'),
    ux_root_dir           => hiera('ux_root_dir')
    ux_admin_host         => hiera('app_admin_host'),
    files_home            => hiera('app_files_dir'),
    require               => Class['::Oaeservice::Deps::Common'],
  }
}