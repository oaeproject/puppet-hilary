class oaeservice::users::admin {

    # The admin group has sudoer access
    group { 'admin': ensure => present }

    # Create all the admin users
    create_resources(oaeadminuser, hiera('admin_users'))

    Group['admin'] -> Oaeadminuser <| |>
}