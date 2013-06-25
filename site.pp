
## Set the path globally

Exec {
    path        => ['/usr/local/sbin', '/usr/local/bin', '/usr/sbin', '/usr/bin', '/sbin', '/bin'],
    environment => "HOME=/root",
}

Cron { environment => 'PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin' }

###############
## EXECUTION ##
###############

# Instantiate the nodetypes and the environment-specific node config
import 'nodetypes.pp'
import 'localconfig/nodes.pp'
