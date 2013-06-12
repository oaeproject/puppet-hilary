class oaeservice::ssh {

    # Export this node's RSA ssh key for all other nodes to have
    @@sshkey { $hostname:
        type => rsa,
        key => $sshrsakey
    }

    # Import every node's RSA ssh key
    Sshkey <<| |>>
}