if [ "$1" = "" -o "$2" = "" -o "$3" = "" ]
then
  echo "Usage: $0 <environment (production, performance)> <hostname> <puppetmaster internal ip>"
  exit
fi

SCRIPT_ENVIRONMENT=$1
SCRIPT_HOSTNAME=$2
SCRIPT_PUPPET_INTERNAL_IP=$3

sudo sm-set-hostname $SCRIPT_HOSTNAME
echo "Pre-reboot setup complete. Please reboot the machine VIA the Joyent admin UI, then run the after-reboot script."