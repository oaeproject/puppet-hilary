if [ "$1" = "" -o "$2" = "" -o "$3" = "" ]
then
  echo "Usage: $0 <environment (production, performance)> <hostname> <puppetmaster internal ip>"
  exit
fi

SCRIPT_ENVIRONMENT=$1
SCRIPT_HOST=$2
SCRIPT_PUPPET_INTERNAL_IP=$3

echo $SCRIPT_HOSTNAME > /etc/hostname
sed -i "s/^127\.0\.1\.1[[:space:]]*localhost/127.0.1.1 $SCRIPT_HOSTNAME localhost/" /etc/hosts
echo "$SCRIPT_PUPPET_INTERNAL_IP puppet" >> /etc/hosts

echo "Pre-reboot setup complete. Please reboot the machine VIA the Joyent admin UI, then run the after-reboot script."