class oaeservice::users::deploy {
    require ::oaeservice::users::admin

    oaeadminuser { 'deploy':
        passwd  => hiera('deploy_user_passwd', undef)
    }

    # Create the deploy user access
    create_resources(oaedeployuseraccess, hiera('admin_users'))
}