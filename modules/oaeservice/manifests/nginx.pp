class oaeservice::nginx {
  require ::oaeservice::deps::common
  require ::oaeservice::deps::package::pcre

  Class['::oaeservice::deps::common'] -> Class['::nginx']
  Class['::oaeservice::deps::package::pcre'] -> Class['::nginx']

  class { '::nginx':
    internal_app_ips                => hiera('app_hosts'),
    internal_etherpad_ips           => hiera('etherpad_internal_hosts', []),

    web_domain                      => hiera('web_domain'),
    app_admin_tenant                => hiera('app_admin_tenant', 'admin'),
    etherpad_external_domain_label  => hiera('etherpad_external_domain_label', 'etherpad'),

    ux_root_dir                     => hiera('ux_root_dir'),
    files_home                      => hiera('app_files_dir')
  }
}