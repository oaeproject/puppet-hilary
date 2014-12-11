class localconfig::ordering {

    ## All these components should be installed before hilary
    Class['::oaeservice::ui']               -> Class['::hilary']
    Class['::redis']                        -> Class['::hilary']
    Class['::elasticsearch']                -> Class['::hilary']
    Class['::dse::cassandra']               -> Class['::hilary']
    Class['::rabbitmq']                     -> Class['::hilary']
}
