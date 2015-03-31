class oaeservice::nginx {
    include ::oaeservice::deps::common
    include ::oaeservice::deps::package::pcre
    include ::oaeservice::deps::apt::nginx

    Class['::oaeservice::deps::common']         -> Class['::nginx']
    Class['::oaeservice::deps::package::pcre']  -> Class['::nginx']

    $web_domains_external = hiera_array('web_domains_external', false)
    $rsyslog_enabled = hiera('rsyslog_enabled', false)
    $rsyslog_host = hiera('rsyslog_host', '127.0.0.1')

    class { '::nginx':
        internal_app_ips                => hiera('app_hosts'),
        internal_etherpad_ips           => hiera('etherpad_internal_hosts', []),
        web_domain                      => hiera('web_domain'),
        app_admin_tenant                => hiera('app_admin_tenant', 'admin'),
        app_ui_path                     => hiera('app_ui_path', '/opt/3akai-ux'),
        files_home                      => hiera('app_files_dir'),
        static_assets_dir               => hiera('static_assets_dir', false),
        rsyslog_enabled                 => $rsyslog_enabled,
        rsyslog_host                    => $rsyslog_host,
    }

    # Plant all the external hosts (e.g., oae.gatech.edu) if they are specified
    if ($web_domains_external) {
        ::nginx::server { $web_domains_external: }
    }

    # Redirect tenancies moved to unity
    $web_domains_redirect = hiera_array('web_domains_redirect', false)
    if ($web_domains_redirect) {
        ::nginx::redirect { $web_domains_redirect: }
    }


}
