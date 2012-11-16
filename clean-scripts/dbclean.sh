#!/bin/bash
# This bash script holds the commands to scrub a cassandra node.

echo 'drop keyspace oae;' > /tmp/clean-oae.cql
/usr/bin/cqlsh -f /tmp/clean-oae.cql
