
################
## RUN STAGES ##
################

## Adding this so that we can disable the puppet agent after everything has run.
## Ensures servers don't take in updates from the puppet master at random times
stage { 'pre': before => Stage['main'], }
stage { 'post': }
Stage['main'] -> Stage['post']

##########
## PATH ##
##########

case $operatingsystem {
  debian, ubuntu: {
    $defaultPath = ['/usr/local/sbin', '/usr/local/bin', '/usr/sbin', '/usr/bin', '/sbin', '/bin']
  }
  solaris, Solaris: {
    $defaultPath = ['/opt/local/gnu/bin', '/opt/local/bin', '/opt/local/sbin', '/usr/bin', '/usr/sbin']
  }
  default: {
    $defaultPath = ['/usr/local/sbin', '/usr/local/bin', '/usr/sbin', '/usr/bin', '/sbin', '/bin']
  }
}
Exec { path => $defaultPath }


###############
## EXECUTION ##
###############

import 'nodetypes'

## Import the nodes.pp of the configured environment.
import 'cassandra/common.pp'
import 'localconfig/nodes.pp'