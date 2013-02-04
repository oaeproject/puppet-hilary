#!/bin/bash
# This bash script holds the commands to scrub and restore a cassandra node.

# Stop cassandra.
/sbin/service cassandra stop

# Stop the opscenter agent.
/sbin/service opscenter-agent stop

# Stop opscenterd if it is on this node.
if [ -f /etc/init.d/opscenterd ] ; then
    /etc/init.d/opscenterd stop
fi

echo 'Sleeping 5s for db service shutdown'
sleep 5

# bring down the axe
killall -9 java

# Delete the logs.
rm -rf /var/log/cassandra/*
rm -rf /var/log/opscenter-agent/*
chown -R cassandra:cassandra /var/log/cassandra

# Delete all the data
rm -rf /data/cassandra/data/oae /var/lib/cassandra/data/oae
rm -rf /data/cassandra/commitlog/* /var/lib/cassandra/commitlog/*
mkdir -p /data/cassandra/data
chown -R cassandra:cassandra /data/cassandra

# Pull latest puppet config and apply it.
# This will also start the cassandra and any opscenter processes again.
cd /root/puppet-hilary
bin/pull.sh
bin/apply.sh