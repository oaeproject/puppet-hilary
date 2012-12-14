#!/bin/bash
# This bash script holds the commands to scrub
# an app server and start fresh.

# Stop the app server.
svcadm disable node-sakai-oae

# Delete the directory.
sudo rm -rf /opt/oae
sudo rm -rf /opt/3akai-ux

# Pull latest puppet config and apply it.
# This will also start the node process again.
cd /home/admin/puppet-hilary
bin/pull.sh
sudo bin/apply.sh

# Set the open file limit for all node processes
sudo prctl -r -t basic -n process.max-file-descriptor -v 32768 -i process `pgrep node`
