class nginx (
    $internal_app_ips,
    $internal_etherpad_ips,
    $web_domain,
    $etherpad_external_domain_label = 'etherpad',
    $app_admin_tenant               = 'admin',
    $ux_root_dir                    = '/opt/3akai-ux',
    $files_home                     = '/opt/files',
    $owner                          = 'nginx',
    $group                          = 'nginx',
    $nginx_dir                      = '/etc/nginx',
    $ssl_default_crt_source         = 'puppet:///modules/localconfig/server.crt',
    $ssl_default_key_source         = 'puppet:///modules/localconfig/server.key',
    $version                        = '1.4.1-1~precise',) {


    #############################
    ## ADDITIONAL PARAM VALUES ##
    #############################

    $nginx_conf_dir = "${nginx_dir}/oae.conf.d"
    $nginx_ssl_dir  = "${nginx_dir}/ssl"


    ###################
    ## NGINX PACKAGE ##
    ###################

    package { 'nginx': ensure => $version }


    ########################
    ## CORE CONFIGURATION ##
    ########################

    $nginx_config_path  = "${nginx_dir}/nginx.conf"
    $nginx_mimes_path   = "${nginx_dir}/nginx.mime.types"

    file { $nginx_conf_dir:
        ensure      => directory,
        mode        => 0640,
        owner       => $owner,
        group       => $group,
        require     => Package['nginx'],
    }

    file { $nginx_ssl_dir:
        ensure      => directory,
        mode        => 0640,
        owner       => $owner,
        group       => $group,
        recurse     => true,
        require     => Package['nginx'],
    }

    file { $nginx_config_path:
        ensure  => present,
        mode    => 0640,
        owner   => $owner,
        group   => $group,
        content => template('nginx/nginx.conf.erb'),
        require => Package['nginx'],
    }

    file { $nginx_mimes_path:
        path    => "${nginx_dir}/nginx.mime.types",
        ensure  => present,
        mode    => 0640,
        owner   => $owner,
        group   => $group,
        content => template('nginx/nginx.mime.types'),
        require => Package['nginx'],
    }


    ################################
    ## ADMIN TENANT CONFIGURATION ##
    ################################

    nginx::server { "${app_admin_tenant}.${web_domain}":
        ssl_crt_source  => $ssl_default_crt_source,
        ssl_key_source  => $ssl_default_key_source,
        template        => 'nginx/admin_tenant_nginx.conf.erb'
    }


    #######################################
    ## DEFAULT USER TENANT CONFIGURATION ##
    #######################################

    nginx::server { $web_domain:
        ssl_crt_source  => $ssl_default_crt_source,
        ssl_key_source  => $ssl_default_key_source,
        server_name     => 'default_server',
    }


    ###################
    ## NGINX SERVICE ##
    ###################

    file { '/etc/init.d/nginx':
        ensure  => present,
        mode    => 0744,
        owner   => $owner,
        group   => $group,
        content => template('nginx/nginx-init-ubuntu.erb'),
    }

    service { 'nginx':
        ensure  => running,
        require => [
            File[$nginx_config_path],
            File[$nginx_mimes_path],
            File['/etc/init.d/nginx'],
        ],
    }

    # Ensure the ::nginx::server resources are applied after the package, but before the service
    Package['nginx'] -> Nginx::Server <| |> -> Service['nginx']
}
