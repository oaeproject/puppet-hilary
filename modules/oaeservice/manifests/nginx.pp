class oaeservice::nginx {
    include ::oaeservice::deps::common
    include ::oaeservice::deps::package::pcre

    Class['::oaeservice::deps::common']         -> Class['::nginx']
    Class['::oaeservice::deps::package::pcre']  -> Class['::nginx']

    $web_domains_external = hiera_array('web_domains_external', false)

    ::apt::source { 'nginx':
        location    => 'http://nginx.org/packages/ubuntu/',
        repos       => 'nginx',
        key         => 'ABF5BD827BD9BF62',
    }

    class { '::nginx':
        internal_app_ips                => hiera('app_hosts'),
        internal_etherpad_ips           => hiera('etherpad_internal_hosts', []),
        web_domain                      => hiera('web_domain'),
        app_admin_tenant                => hiera('app_admin_tenant', 'admin'),
        ux_root_dir                     => hiera('ux_root_dir'),
        files_home                      => hiera('app_files_dir')
    }

    # Plant all the external hosts (e.g., oae.gatech.edu) if they are specified
    if ($web_domains_external) {
        ::nginx::server { $web_domains_external: }
    }
}