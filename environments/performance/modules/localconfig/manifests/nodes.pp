
###############
## WEB PROXY ##
###############

node 'web0' inherits basenode {
  class { 'machine::nginx': index => 0 }
}

node 'web1' inherits basenode {
  class { 'machine::nginx': index => 1 }
}



###############
## APP NODES ##
###############

node 'app0' inherits app { $nodesuffix = 0 }

node 'app1' inherits basenode {
  class { 'machine::app': index => 1 }
}

node 'app2' inherits basenode {
  class { 'machine::app': index => 2 }
}

node 'app3' inherits basenode {
  class { 'machine::app': index => 3 }
}



####################
## ACTIVITY NODES ##
####################

node 'activity0' inherits basenode {
  class { 'machine::activity::performance': index => 0 }
}

node 'activity1' inherits basenode {
  class { 'machine::activity::performance': index => 1 }
}

node 'activity2' inherits basenode {
  class { 'machine::activity::performance': index => 2 }
}



#####################
## CASSANDRA NODES ##
#####################

node 'db0' inherits baselinuxnode {
  class { 'machine::db': index => 0 }
  opscenter { 'opscenter': require => Class['machine::db'] }
}

node 'db1' inherits baselinuxnode {
  class { 'machine::db': index => 1 }
}

node 'db2' inherits baselinuxnode {
  class { 'machine::db': index => 2 }
}

node 'db3' inherits baselinuxnode {
  class { 'machine::db': index => 3 }
}

node 'db4' inherits baselinuxnode {
  class { 'machine::db': index => 4 }
}

node 'db5' inherits baselinuxnode {
  class { 'machine::db': index => 5 }
}



##################
## SEARCH NODES ##
##################

node 'search0' inherits baselinuxnode {
  class { 'machine::elasticsearch': index => 0 }
}

node 'search1' inherits baselinuxnode {
  class { 'machine::elasticsearch': index => 1 }
}



#################
## REDIS NODES ##
#################

node 'cache-master' inherits basenode {
  class { 'machine': type_code => 'cache', suffix => '-master' }
  redis { 'redis': }
}

node 'cache-slave' inherits basenode {
  class { 'machine': type_code => 'cache', suffix => '-slave' }
  redis { 'redis': slave_of => $localconfig::redis_hosts[0] }
}

node 'activity-cache-master' inherits activity-cache { $nodesuffix = '-master' }

node 'activity-cache-slave' inherits basenode {
  class { 'machine': type_code => 'activity-cache', suffix => '-slave' }
  redis { 'redis':
    eviction_maxmemory  => 3758096384,
    eviction_policy     => 'volatile-ttl',
    eviction_samples    => 3,
    slave_of            => $localconfig::activity_redis_hosts[0]
  }
}

#####################
## MESSAGING NODES ##
#####################

node 'mq-master' inherits basenode {
  class { 'machine': type_code => 'mq', suffix => '-master' }
  rabbitmq { 'rabbitmq':
    listen_address  => $localconfig::mq_hosts_internal[0]['host'],
    listen_port     => $localconfig::mq_hosts_internal[0]['port'],
  }
}



#############################
## PREVIEW PROCESSOR NODES ##
#############################

node 'pp0' inherits baselinuxnode {
  class { 'machine::pp': index => 0 }
}

node 'pp1' inherits baselinuxnode {
  class { 'machine::pp': index => 1 }
}

node 'pp2' inherits baselinuxnode {
  class { 'machine::pp': index => 2 }
}



####################
## ETHERPAD NODES ##
####################

node 'ep0' inherits basenode {
  class { 'machine::ep': index => 0 }
}

node 'ep1' inherits basenode {
  class { 'machine::ep': index => 1 }
}



#################
## SYSLOG NODE ##
#################

node 'syslog' inherits baselinuxnode {
  class { 'machine::syslog': }
}



#############
## BASTION ##
#############

node 'bastion' inherits baselinuxnode {
  class { 'machine::bastion': }
}



