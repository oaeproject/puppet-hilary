class oaeservice::hosts {
    
    ## Realize the hosts of all nodes
    Host<<| |>>

    @@host { "$::certname": ip => $::ipaddress_eth1 }
}