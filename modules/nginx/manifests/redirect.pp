define nginx::redirect (
    $ssl_crt_source     = "puppet:///modules/localconfig/ssl/*.${web_domain_redirect_from}/server.crt",
    $ssl_key_source     = "puppet:///modules/localconfig/ssl/*.${web_domain_redirect_from}/server.key",
    $server_name        = $name,
    $template           = 'nginx/redirect_tenant_nginx.conf.erb',) {

    # Ensure the top-level nginx class exists
    include ::nginx


    # Grab config properties from the central nginx class into scope
    $owner = $::nginx::owner
    $group = $::nginx::group
    $nginx_dir = $::nginx::nginx_dir
    $ssl_policy = $::nginx::ssl_policy

    ############################
    ## SERVER SSL CERTIFICATE ##
    ############################

    $nginx_ssl_dir = $::nginx::nginx_ssl_dir
    $ssl_host_dir = "${nginx_ssl_dir}/*.${web_domain_redirect_from}"
    $ssl_crt_path = "${ssl_host_dir}/server.crt"
    $ssl_key_path = "${ssl_host_dir}/server.key"

    ###############################
    ## SERVER CONFIGURATION FILE ##
    ###############################

    # Build the nginx configuration file path for this server
    $nginx_conf_dir = $::nginx::nginx_conf_dir
    $server_conf_path = "${nginx_conf_dir}/${name}.${web_domain_redirect_from}.conf"

    # Plant the configuration file
    file { $server_conf_path:
        ensure  => present,
        mode    => 0640,
        owner   => $owner,
        group   => $group,
        content => template($template),
    }
}
