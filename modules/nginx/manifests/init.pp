class nginx (
    $internal_app_ips,
    $internal_etherpad_ips,
    $web_domain,
    $app_admin_tenant               = 'admin',
    $app_ui_path                    = '/opt/3akai-ux',
    $files_home                     = '/opt/files',
    $owner                          = 'nginx',
    $group                          = 'nginx',
    $nginx_dir                      = '/etc/nginx',
    $base_read_timeout              = 5,
    $rate_limit_api                 = true,
    $ssl_policy                     = 'redirect_http',
    $ssl_default_crt_source         = 'puppet:///modules/localconfig/ssl/default/server.crt',
    $ssl_default_key_source         = 'puppet:///modules/localconfig/ssl/default/server.key',
    $static_assets_dir              = false,
    $version                        = '1.4.3-1~precise',) {


    #############################
    ## ADDITIONAL PARAM VALUES ##
    #############################

    $nginx_conf_dir = "${nginx_dir}/oae.conf.d"
    $nginx_ssl_dir  = "${nginx_dir}/ssl"

    # Validate the SSL policy
    #  * allow_http: We route HTTP requests just the same as HTTPS
    #  * redirect_http: We redirect all HTTP to HTTPS
    #  * deny_http: We simply do not listen on HTTP.
    #
    if ! ($ssl_policy in ['allow_http', 'deny_http', 'redirect_http']) {
        fail("Invalid ssl_policy of \"${ssl_policy}\" provided to class ::nginx. Should be one of: allow_http, deny_http, redirect_http")
    }

    ###################
    ## NGINX PACKAGE ##
    ###################

    package { 'nginx': ensure => $version }

    group { $group:
        ensure  => 'present',
        require => Package['nginx'],
    }

    user { $owner:
        ensure      => 'present',
        groups      => $group,
        comment     => 'This user was created by Puppet',
        managehome  => 'true',
        require     => Group[$group],
    }

    ########################
    ## CORE CONFIGURATION ##
    ########################

    $nginx_config_requires = [Package['nnginx'], User[$owner]]
    $nginx_config_path  = "${nginx_dir}/nginx.conf"
    $nginx_mimes_path   = "${nginx_dir}/nginx.mime.types"

    file { $nginx_conf_dir:
        ensure      => directory,
        mode        => 0640,
        owner       => $owner,
        group       => $group,
        require     => $nginx_config_requires,
    }

    file { $nginx_ssl_dir:
        ensure      => directory,
        mode        => 0640,
        owner       => $owner,
        group       => $group,
        recurse     => true,
        require     => $nginx_config_requires,
    }

    file { $nginx_config_path:
        ensure  => present,
        mode    => 0640,
        owner   => $owner,
        group   => $group,
        content => template('nginx/nginx.conf.erb'),
        require => $nginx_config_requires,
    }

    file { $nginx_mimes_path:
        path    => "${nginx_dir}/nginx.mime.types",
        ensure  => present,
        mode    => 0640,
        owner   => $owner,
        group   => $group,
        content => template('nginx/nginx.mime.types'),
        require => $nginx_config_requires,
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
