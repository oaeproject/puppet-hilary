class oaeservice::redis ($master_cache_var = false) {

    # If the service is a slave instance, we configure the master IP in as the slaveof
    case $master_cache_var {
        false:      { $slave_of = false }
        default:    { $slave_of = hiera($master_cache_var) }
    }

    class { '::redis': slave_of => $slave_of }
}
