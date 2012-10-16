#!/bin/bash
# This bash script holds the commands to scrub
# a cassandra node.

# Stop cassandra.
/sbin/service cassandra stop

# Stop the opscenter agent.
/sbin/service opscenter-agent stop

# Stop opscenterd if it is on this node.
if [ -f /etc/init.d/opscenterd ] ; then
    /etc/init.d/opscenterd stop
fi

# Delete the logs.
rm -rf /var/log/cassandra/*
rm -rf /var/log/opscenter-agent/*
chown -R cassandra:cassandra /var/log/cassandra

# Delete all the data
find /var/lib/cassandra/data/oae/ -regex "^.*\.db$" -maxdepth 2 -exec rm -rf {} \;
rm -rf /var/lib/cassandra/commitlog/*
chown -R cassandra:cassandra /var/lib/cassandra

# Restore a correct snapshot.
# The name of the snapshot sits in ~/.snapshotname
if [ -f ~/.snapshotname ] ; then
    CFS=`ls /var/lib/cassandra/data/oae`
    SNAPSHOTNAME=`cat ~/.snapshotname`
    echo "Restoring ${SNAPSHOTNAME}."
    for cf in $CFS ; do
        cp -R /var/lib/cassandra/data/oae/${cf}/snapshots/${SNAPSHOTNAME}/* "/var/lib/cassandra/data/oae/${cf}"
    done;
fi

# Pull latest puppet config and apply it.
# This will also start the cassandra and any opscenter processes again.
cd /root/puppet-hilary
bin/pull.sh
bin/apply.sh