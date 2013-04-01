
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

node 'search0' inherits search {
  $nodesuffix = 0
  hiera_include(classes)
}

node 'search1' inherits search {
  $nodesuffix = 1
  hiera_include(classes)
}



#################
## REDIS NODES ##
#################

node 'cache-master' inherits cache {
  $nodesuffix = '-master'
  hiera_include(classes)
}

node 'cache-slave' inherits cache {
  $nodesuffix = '-slave'
  hiera_include(classes)
}

node 'activity-cache-master' inherits activity-cache {
  $nodesuffix = '-master'
  hiera_include(classes)
}

node 'activity-cache-slave' inherits activity-cache {
  $nodesuffix = '-slave'
  hiera_include(classes)
}

#####################
## MESSAGING NODES ##
#####################

node 'mq-master' inherits mq {
  $nodesuffix = '-master'
  hiera_include(classes)
}

node 'mq-slave' inherits mq {
  $nodesuffix = '-slave'
  hiera_include(classes)
}

#############################
## PREVIEW PROCESSOR NODES ##
#############################

node 'pp0' inherits pp {
  $nodesuffix = 0
  hiera_include(classes)
}

node 'pp1' inherits pp {
  $nodesuffix = 1
  hiera_include(classes)
}

node 'pp2' inherits pp {
  $nodesuffix = 2
  hiera_include(classes)
}


####################
## ETHERPAD NODES ##
####################

node 'ep0' inherits ep {
  $nodesuffix = 0
  hiera_include(classes)
}

node 'ep1' inherits ep {
  $nodesuffix = 1
  hiera_include(classes)
}



#################
## SYSLOG NODE ##
#################

node 'syslog' {
  $nodetype = 'syslog'
  hiera_include(classes)
}



#############
## BASTION ##
#############

node 'bastion' {
  $nodetype = 'bastion'
  hiera_include(classes)
}



