class oaeservice::redis ($is_slave) {

    # If the service is a slave instance, we configure the master IP in as the slaveof
    $master_host = hieraptr('cache_host_master')
    case $is_slave {
        false:      { $slave_of = false }
        default:    { $slave_of = $master_host }
    }

    class { '::redis': slave_of => $slave_of }
}
