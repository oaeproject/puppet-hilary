define nginx::server (
    $ssl_crt_source     = "puppet:///modules/localconfig/ssl/${name}/server.crt",
    $ssl_key_source     = "puppet:///modules/localconfig/ssl/${name}/server.key",
    $server_name        = $name,
    $template           = 'nginx/user_tenant_nginx.conf.erb',
    $favicon            = undef) {

    # Ensure the top-level nginx class exists
    include ::nginx


    # Grab config properties from the central nginx class into scope
    $owner = $::nginx::owner
    $group = $::nginx::group
    $app_ui_path = $::nginx::app_ui_path
    $files_home = $::nginx::files_home
    $nginx_dir = $::nginx::nginx_dir
    $rate_limit_api = $::nginx::rate_limit_api
    $ssl_policy = $::nginx::ssl_policy
    $static_assets_dir = $::nginx::static_assets_dir

    # We need the internal etherpad ips to bind the etherpad path-based sharding to each host
    $internal_etherpad_ips = $::nginx::internal_etherpad_ips


    ############################
    ## SERVER SSL CERTIFICATE ##
    ############################

    $nginx_ssl_dir = $::nginx::nginx_ssl_dir
    $ssl_host_dir = "${nginx_ssl_dir}/${name}"
    $ssl_crt_path = "${ssl_host_dir}/server.crt"
    $ssl_key_path = "${ssl_host_dir}/server.key"

    nginx::ssl { $ssl_host_dir:
        ssl_crt_source  => $ssl_crt_source,
        ssl_crt_path    => $ssl_crt_path,
        ssl_key_source  => $ssl_key_source,
        ssl_key_path    => $ssl_key_path,
    }


    ###############################
    ## SERVER CONFIGURATION FILE ##
    ###############################

    # Build the nginx configuration file path for this server
    $nginx_conf_dir = $::nginx::nginx_conf_dir
    $server_conf_path = "${nginx_conf_dir}/${name}.conf"

    # Plant the configuration file
    file { $server_conf_path:
        ensure  => present,
        mode    => 0640,
        owner   => $owner,
        group   => $group,
        content => template($template),
    }
}
