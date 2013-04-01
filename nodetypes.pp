
#
# Simply define the nodetypes, setting the $nodetype variable, which is used by the hiera data
#

# Hilary nodes
node activity       { $nodetype = 'activity' }
node app            { $nodetype = 'app' }
node pp             { $nodetype = 'pp' }

# Cache nodes
node activity-cache { $nodetype = 'activity-cache' }
node cache          { $nodetype = 'cache' }

node db             { $nodetype = 'db' }

node mq             { $nodetype = 'mq' }

node search         { $nodetype = 'search' }

node ep             { $nodetype = 'ep' }
