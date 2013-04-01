
###############
## WEB PROXY ##
###############

node 'web0' inherits web {
  $nodesuffix = 0
  hiera_include(classes)
}

node 'web1' inherits web {
  $nodesuffix = 1
  hiera_include(classes)
}



###############
## APP NODES ##
###############

node 'app0' inherits app {
  $nodesuffix = 0
  hiera_include(classes)
}

node 'app1' inherits app {
  $nodesuffix = 1
  hiera_include(classes)
}

node 'app2' inherits app {
  $nodesuffix = 2
  hiera_include(classes)
}

node 'app3' inherits app {
  $nodesuffix = 3
  hiera_include(classes)
}



####################
## ACTIVITY NODES ##
####################

node 'activity0' inherits activity {
  $nodesuffix = 0
  hiera_include(classes)
}

node 'activity1' inherits activity {
  $nodesuffix = 1
  hiera_include(classes)
}

node 'activity2' inherits activity {
  $nodesuffix = 2
  hiera_include(classes)
}



#####################
## CASSANDRA NODES ##
#####################

node 'db0' inherits db {
  $nodesuffix = 0
  hiera_include(classes)
}

node 'db1' inherits db {
  $nodesuffix = 1
  hiera_include(classes)
}

node 'db2' inherits db {
  $nodesuffix = 2
  hiera_include(classes)
}

node 'db3' inherits db {
  $nodesuffix = 3
  hiera_include(classes)
}

node 'db4' inherits db {
  $nodesuffix = 4
  hiera_include(classes)
}

node 'db5' inherits db {
  $nodesuffix = 5
  hiera_include(classes)
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



