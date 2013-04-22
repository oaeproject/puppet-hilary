class oaeservice::nginx {
  require ::oaeservice::deps::common
  require ::oaeservice::deps::package::pcre

  Class['::oaeservice::deps::common'] -> Class['::nginx']
  Class['::oaeservice::deps::package::pcre'] -> Class['::nginx']

  class { '::nginx':
    internal_app_ips      => hiera('app_hosts'),
    internal_etherpad_ips => hiera('etherpad_hosts', []),
    ux_root_dir           => hiera('ux_root_dir'),
    ux_admin_host         => hiera('app_admin_host'),
    files_home            => hiera('app_files_dir')
  }
}