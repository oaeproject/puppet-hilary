class oaeservice::hosts {

    ## Collect all 'host' resources from all other machines in the cluster
    Host <<| |>>

    ## Export the host entry of this resource so it can be acquired by all other nodes
    @@host { "$::clientcert": ip => $::ipaddress_eth1 }

}