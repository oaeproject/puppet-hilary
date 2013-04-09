# Set the host
echo puppet >/etc/hostname
sed -i 's/^127\.0\.1\.1[[:space:]]*localhost/127.0.1.1 localhost puppet/' /etc/hosts
echo 'Host has been set. Reboot the machine then run the after-reboot script.'