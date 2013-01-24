#!/bin/bash
# This bash script holds the commands to scrub
# a web server and start fresh.

# Stop nginx
svcadm disable nginx

# Delete the directory.
sudo rm -rf /opt/3akai-ux

# Pull latest puppet config and apply it.
# This will also start the node process again.
cd /home/admin/puppet-hilary
bin/pull.sh
sudo bin/apply.sh
