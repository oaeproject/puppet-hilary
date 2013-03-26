SCRIPT_HOSTNAME=$1
SCRIPT_PUPPET_INTERNAL_IP=$2

echo $SCRIPT_HOSTNAME > /etc/hostname
sed -i "s/^127\.0\.1\.1[[:space:]]*localhost/127.0.1.1 $SCRIPT_HOSTNAME localhost/" /etc/hosts
echo "$SCRIPT_PUPPET_INTERNAL_IP puppet" >> /etc/hosts

echo "Pre-reboot setup complete. Please reboot the machine VIA the Joyent admin UI, then run the after-reboot script."