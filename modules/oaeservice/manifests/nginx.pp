class oaeservice::nginx {
  include ::oaeservice::deps::common

  class { '::nginx':
    internal_app_ips      => hiera('app_hosts'),
    internal_etherpad_ips => hiera('etherpad_hosts'),
    ux_root_dir           => hiera('ux_root_dir'),
    ux_admin_host         => hiera('app_admin_host'),
    files_home            => hiera('app_files_dir'),
    require               => Class['::Oaeservice::Deps::Common'],
  }
}