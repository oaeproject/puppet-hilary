
################################
## CUSTOM MACHINE DEFINITIONS ##
################################

node baselinuxnode {
  class { 'service::firewall::open': }
}

class machine::activity::performance ($index) inherits machine::activity::base {
  Class['service::munin::client'] { suffix => $index }
  Class['service::hilary::activity'] { dedicated_redis_host => $localconfig::activity_redis_hosts[0] }
}


###############
## WEB PROXY ##
###############

node 'web0' {
  class { 'machine::nginx': index => 0 }
}

node 'web1' {
  class { 'machine::nginx': index => 1 }
}



###############
## APP NODES ##
###############

node 'app0' {
  class { 'machine::app': index => 0 }
}

node 'app1' {
  class { 'machine::app': index => 1 }
}

node 'app2' {
  class { 'machine::app': index => 2 }
}

node 'app3' {
  class { 'machine::app': index => 3 }
}



####################
## ACTIVITY NODES ##
####################

node 'activity0' {
  class { 'machine::activity::performance': index => 0 }
}

node 'activity1' {
  class { 'machine::activity::performance': index => 1 }
}

node 'activity2' {
  class { 'machine::activity::performance': index => 2 }
}



#####################
## CASSANDRA NODES ##
#####################

node 'db0' {
  class { 'machine::db': index => 0 }
  class { 'opscenter': require => Class['cassandra::base'] }
}

node 'db1' {
  class { 'machine::db': index => 1 }
}

node 'db2' {
  class { 'machine::db': index => 2 }
}

node 'db3' {
  class { 'machine::db': index => 3 }
}

node 'db4' {
  class { 'machine::db': index => 4 }
}

node 'db5' {
  class { 'machine::db': index => 5 }
}



##################
## SEARCH NODES ##
##################

node 'search0' {
  class { 'machine::elasticsearch': index => 0 }
}

node 'search1' {
  class { 'machine::elasticsearch': index => 1 }
}



#################
## REDIS NODES ##
#################

node 'cache-master' {
  class { 'machine': type_code => 'cache', suffix => '-master' }
  class { 'redis': }
}

node 'cache-slave' {
  class { 'machine': type_code => 'cache', suffix => '-slave' }
  class { 'redis': slave_of => $localconfig::redis_hosts[0] }
}

node 'activity-cache-master' {
  class { 'machine': type_code => 'activity-cache', suffix => '-master' }
  class { 'redis':
    eviction_maxmemory  => 3758096384,
    eviction_policy     => 'volatile-ttl',
    eviction_samples    => 3
  }
}

node 'activity-cache-slave' {
  class { 'machine': type_code => 'activity-cache', suffix => '-slave' }
  class { 'redis':
    eviction_maxmemory  => 3758096384,
    eviction_policy     => 'volatile-ttl',
    eviction_samples    => 3,
    slave_of            => $localconfig::activity_redis_hosts[0]
  }
}

#####################
## MESSAGING NODES ##
#####################

node 'mq-master' {
  class { 'machine': type_code => 'mq', suffix => '-master' }
  class { 'rabbitmq':
    listen_address  => $localconfig::mq_hosts_internal[0]['host'],
    listen_port     => $localconfig::mq_hosts_internal[0]['port'],
  }
}



#############################
## PREVIEW PROCESSOR NODES ##
#############################

node 'pp0' {
  class { 'machine::pp': index => 0 }
}

node 'pp1' {
  class { 'machine::pp': index => 1 }
}

node 'pp2' {
  class { 'machine::pp': index => 2 }
}



####################
## ETHERPAD NODES ##
####################

node 'ep0' {
  class { 'machine::ep': index => 0 }
}

node 'ep1' {
  class { 'machine::ep': index => 1 }
}



#################
## SYSLOG NODE ##
#################

node 'syslog' {
  class { 'machine::syslog': }
}



#############
## BASTION ##
#############

node 'bastion' {
  class { 'machine::bastion': }
}



