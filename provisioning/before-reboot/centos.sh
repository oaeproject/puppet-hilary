SCRIPT_HOSTNAME=$1
SCRIPT_PUPPET_INTERNAL_IP=$2

# set HOSTNAME in /etc/sysconfig/network and /etc/hosts
sed -i -e 's/localhost.localdomain/$SCRIPT_HOSTNAME/g' /etc/sysconfig/network
sed -i 's/localhost /$SCRIPT_HOSTNAME localhost /g' /etc/hosts
echo "$SCRIPT_HOSTNAME" > /etc/hostname
echo "$SCRIPT_PUPPET_INTERNAL_IP puppet" /etc/hosts

echo "Pre-reboot setup complete. Please reboot the machine VIA the Joyent admin UI, then run the after-reboot script."