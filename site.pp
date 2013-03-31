
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

include epel

# Instantiate the nodetypes and the environment-specific node config
import 'nodetypes.pp'
import 'localconfig/nodes.pp'
