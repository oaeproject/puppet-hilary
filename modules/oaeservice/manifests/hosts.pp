class oaeservice::hosts {
    host { "$::certname": ip => $::ipaddress_eth1 }
}