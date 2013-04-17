class oaeservice::hosts {
    host { "$::clientcert": ip => $::ipaddress_eth1 }
}