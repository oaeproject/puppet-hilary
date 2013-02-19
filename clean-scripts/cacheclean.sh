#!/bin/bash
# This bash script holds the commands to scrub
# a redis instance and start fresh

# Pull latest puppet config and apply it.
cd /home/admin/puppet-hilary
bin/pull.sh
sudo bin/apply.sh

# Flush the redis data
redis-cli flushall
