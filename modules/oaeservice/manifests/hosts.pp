class oaeservice::hosts {
    Host <<| |>>

    @@host { "$::clientcert": ip => $::ipaddress_eth1 }
}