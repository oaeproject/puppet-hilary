class localconfig::ordering {

    ## All these components should be installed before hilary
    Class['::oaeservice::deps::pp']         -> Class['::oaeservice::hilary']
    Class['::oaeservice::ui']               -> Class['::oaeservice::hilary']
    Class['::redis']                        -> Class['::oaeservice::hilary']
    Class['::oaeservice::elasticsearch']    -> Class['::oaeservice::hilary']
    Class['::oaeservice::cassandra']        -> Class['::oaeservice::hilary']
    Class['::oaeservice::mq']               -> Class['::oaeservice::hilary']

    ## After the app server is installed and ready, then setup nginx
    Class['::oaeservice::hilary']           -> Class['::oaeservice::nginx']
}