class localconfig::ordering {

    ## All these components should be installed before hilary
    Class['::oaeservice::deps::pp']         -> Class['::hilary']
    Class['::oaeservice::ui']               -> Class['::hilary']
    Class['::redis']                        -> Class['::hilary']
    Class['::elasticsearch']                -> Class['::hilary']
    Class['::cassandra']                    -> Class['::hilary']
    Class['::rabbitmq::server']             -> Class['::hilary']

    ## After the app server is installed and ready, then setup nginx
    Class['::hilary']                       -> Class['::nginx']

    ## After the app server is installed, setup the qa-automation.
    Class['::hilary']                       -> Class['::oaeqaautomation']
}
