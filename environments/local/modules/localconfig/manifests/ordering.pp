class localconfig::ordering {

    ## All these components should be installed before hilary
    Class['::ui']               -> Class['::hilary']
    Class['::redis']            -> Class['::hilary']
    Class['::elasticsearch']    -> Class['::hilary']
    Class['::cassandra']        -> Class['::hilary']
    Class['::rabbitmq::server'] -> Class['::hilary']

}
