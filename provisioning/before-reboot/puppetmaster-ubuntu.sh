echo puppet >/etc/hostname
sed -i 's/^127\.0\.1\.1[[:space:]]*localhost/127.0.1.1 localhost puppet/' /etc/hosts
echo "Pre-reboot setup complete. Please reboot the machine VIA the Joyent admin UI, then run the after-reboot script."