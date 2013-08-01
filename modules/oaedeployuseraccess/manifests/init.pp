#
# == Resource: oaedeployuseraccess
#
# Note: Params $passwd and $groups are not expected to be used. The only reason they're specified
# is so that the same set of hashes used for oaeadminuser can be used for this resource. Helps with
# create_resources functionality for dynamically creating users from config
#
define oaedeployuseraccess ($pubkey, $pubkey_type = 'ssh-rsa', $passwd = undef, $groups = 'admin') {
    
    # Simply apply an ssh key granting access from the pubkey to the target deploy user
    ssh_authorized_key { "${name} access to deploy":
        ensure  => 'present',
        type    => $pubkey_type,
        key     => $pubkey,
        user    => 'deploy',
        require => User['deploy', $name],
    }
}