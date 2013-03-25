
## Set the path for exec resources
case $operatingsystem {
  debian, ubuntu: {
    $path = ['/usr/local/sbin', '/usr/local/bin', '/usr/sbin', '/usr/bin', '/sbin', '/bin']
  }
  solaris, Solaris: {
    $path = ['/opt/local/gnu/bin', '/opt/local/bin', '/opt/local/sbin', '/usr/bin', '/usr/sbin']
  }
  default: {
    $path = ['/usr/local/sbin', '/usr/local/bin', '/usr/sbin', '/usr/bin', '/sbin', '/bin']
  }
}
Exec { path => $path }

import 'nodetypes'

## Import the nodes.pp of the configured environment.
import 'cassandra/common.pp'
import 'localconfig/nodes.pp'