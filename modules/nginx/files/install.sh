#!/usr/bin/sh

# This script will install nginx if it's not installed or the correct version.


BINARY='/opt/local/sbin/nginx'
REQUIRED_VERSION='1.3.14'

function installNginx {
    echo "Installing NGINX"
    cd /tmp
    wget http://nginx.org/download/nginx-${REQUIRED_VERSION}.tar.gz
    tar -zxvf nginx-${REQUIRED_VERSION}.tar.gz
    cd nginx-${REQUIRED_VERSION}
    ./configure --user=www --group=www --with-ld-opt='-L/opt/local/lib -Wl,-R/opt/local/lib' --prefix=/opt/local --sbin-path=/opt/local/sbin --conf-path=/opt/local/etc/nginx/nginx.conf --pid-path=/var/db/nginx/nginx.pid --lock-path=/var/db/nginx/nginx.lock --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log --http-client-body-temp-path=/var/db/nginx/client_body_temp --http-proxy-temp-path=/var/db/nginx/proxy_temp --http-fastcgi-temp-path=/var/db/nginx/fstcgi_temp --with-mail_ssl_module --with-http_ssl_module --with-http_dav_module --with-http_realip_module --with-ipv6 --with-http_stub_status_module
    make
    sudo make install
}

# If we can't find nginx, we should install it.
if [[ ! -f "${BINARY}" ]] ; then
    installNginx
else
    # Check that we have the required version installed.
    INSTALLED_VERSION=$($BINARY -v 2>&1)
    if [[ "$INSTALLED_VERSION" != *"$REQUIRED_VERSION"* ]] ; then
        installNginx
    else
        echo "Nothing to do, the correct version of nginx was found."
    fi
fi