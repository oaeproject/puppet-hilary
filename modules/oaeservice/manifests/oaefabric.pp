class oaeservice::oaefabric {
    include ::oaeservice::deps::package::fabric

    $git_source = hiera('fabric_git_source', 'https://github.com/oaeproject/oae-fabric')
    $git_revision = hiera('fabric_git_revision', 'master')
    $app_root_dir = hiera('app_root_dir')
    $ux_root_dir = hiera('ux_root_dir')

    $deploy_home_dir = '/home/deploy'

    # Check out the oae-fabric repo. The deploy username is 'deploy', we'll put it in their home directory
    vcsrepo { "${deploy_home_dir}/oae-fabric":
        ensure      => latest,
        provider    => git,
        source      => $git_source,
        revision    => $git_revision,
        require     => Oaeadminuser['deploy'],
    }

    # Set the .fabricrc for the deploy user
    file { "${deploy_home_dir}/.fabricrc":
        ensure  => 'file',
        content => template('oaeservice/oaefabric/.fabricrc.erb')
    }
}