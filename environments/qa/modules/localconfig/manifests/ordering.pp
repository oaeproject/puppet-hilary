class localconfig::ordering {

    ## All these components should be installed before hilary
    Class['::oaeservice::ui']               -> Class['::hilary']
    Class['::redis']                        -> Class['::hilary']
    Class['::elasticsearch']                -> Class['::hilary']
    Class['::dse::cassandra']               -> Class['::hilary']
    Class['::rabbitmq::server']             -> Class['::hilary']

    ## After the app server is installed, setup the qa-automation.
    Class['::hilary']                       -> Class['::oaeqaautomation']
}
