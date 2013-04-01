
#
# Simply define the nodetypes, setting the $nodetype variable, which is used by the hiera data
#

node base { }

# Hilary nodes
node activity inherits base         { $nodetype = 'activity' }
node app inherits base              { $nodetype = 'app' }
node pp inherits base               { $nodetype = 'pp' }

# Cache nodes
node activity-cache inherits base   { $nodetype = 'activity-cache' }
node cache inherits base            { $nodetype = 'cache' }

node mq inherits base               { $nodetype = 'mq' }

node search inherits base           { $nodetype = 'search' }

node ep inherits base               { $nodetype = 'ep' }
