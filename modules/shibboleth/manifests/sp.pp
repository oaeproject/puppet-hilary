class shibboleth::sp (
        # The entity ID of the Shibboleth service provider. e.g.: https://sp.oaeproject.org/shibboleth
        $entity_id,

        # The name of the key that is used. e.g.: web0
        $keyname,

        # The subjectname that is used in the certificate. e.g.: CN=web0
        $subjectname,

        # An object where each value is an object that contains the mapping for the `remote_user` attribute and the `hostname` they will be available at
        $shibboleth_hosts = {},

        # An array of strings. Each string is an internal hostname where an appserver is running
        $app_hosts = []
    ) {

    # Ensure that the required shibboleth packages have been installed
    package { 'shibboleth-sp2-schemas':
        ensure => installed,
    }
    package {'libshibsp-dev':
        ensure  => installed,
        require => Package['shibboleth-sp2-schemas'],
    }

    package {'libshibsp-doc':
        ensure  => installed,
        require => [Package['libshibsp-dev'], Package['shibboleth-sp2-schemas']],
    }
    package {'opensaml2-tools':
        ensure  => installed,
        require => [Package['libshibsp-dev'], Package['shibboleth-sp2-schemas']],
    }
    package {'libapache2-mod-shib2':
        ensure  => installed,
        require => [Package['libshibsp-dev'], Package['shibboleth-sp2-schemas']],
    }

    # Configure the shibboleth SP config
    file { '/etc/shibboleth/shibboleth2.xml':
        ensure  => present,
        content => template('shibboleth/shibboleth2.xml.erb'),
        require => Package['libapache2-mod-shib2'],
    }

    file { '/etc/shibboleth/sp-key.pem':
        ensure  => present,
        content => template('shibboleth/sp-key.pem'),
        require => Package['libapache2-mod-shib2'],
    }

    file { '/etc/shibboleth/sp-cert.pem':
        ensure  => present,
        content => template('shibboleth/sp-cert.pem'),
        require => Package['libapache2-mod-shib2'],
    }

    # A bit of a hack, but our metadata file needs the base64 part of the certicate
    $raw_certificate = template('shibboleth/sp-cert.pem')
    $certificate = inline_template("<%= @raw_certificate.split('-----')[2].strip %>")

    file { '/opt/shibboleth-sp':
        ensure  =>  directory,
    }
    # Generate a metadata file that will contain all our tenant hostnames
    file { '/opt/shibboleth-sp/metadata.xml':
        ensure  => present,
        content => template('shibboleth/metadata-sp.xml.erb'),
        require => File['/opt/shibboleth-sp'],
    }

    # Install apache
    class { 'apache':
        # We don't need a default vhost as that starts listening on port 80 and conflicts with nginx
        default_vhost  => false
    }

    # We do need to listen on port 8080 as that is where nginx will proxy shib requests to
    apache::listen { '8080': }

    # Enable the apache shibboleth module
    apache::mod { 'shib2':
        id   => 'mod_shib',
        path => '/usr/lib/apache2/modules/mod_shib_22.so',
    }

    # Enable the proxy modules
    include apache::mod::proxy
    include apache::mod::proxy_http
    include apache::mod::proxy_balancer

    # Generate the balancer cluster and its members
    apache::balancer { 'appnodes':
        collect_exported  => false
    }
    define oae::balancermember {
        apache::balancermember { $name:
            balancer_cluster    => 'appnodes',
            url                 => "http://${name}:2001",
        }
    }
    oae::balancermember { $app_hosts: }

    # We need to apply multiple apache::vhost resources. Unfortunately, we can't pass the $shibboleth_hosts
    # object as the namevar AND use the namevar in the parameters (for the `servername` property)
    # That's why we wrap it in our own oae::vhost. This is how we can iterate over the $shibboleth_hosts
    # array AND get the value of the namevar in the properties.
    define oae::vhost (
        $hostname,
        $remote_user
    ) {

        apache::vhost { $hostname:
            port => '8080',

            # We need to pass the url the user arrived at
            servername => "http://${hostname}:80",

            # Unfortunately, the `docroot` parameter is required by the apache::vhost module
            # It's not exposed to users anywhere though
            docroot => '/opt/3akai-ux',

            # apache::vhost's other parameters have some support for proxy passing and Location blocks
            # but not in the way we need it. Therefor we use a custom fragment
            custom_fragment => "
                # We turn canonical resolution **OFF**, even though the shibboleth documentation claims you should enable it.
                # We can't do this as our web server might host multiple endpoints
                UseCanonicalName Off

                # Keep the host header when proxying the request to the app server
                ProxyPreserveHost On

                # Dont proxy anything under /Shibboleth.sso to the app server as that should go straight to Shibboleth.
                # Keep in mind that /Shibboleth.sso/Metadata is outputted by nginx, as the default Shibboleth metadata files
                # dont suit us very well (they only include the hostname for the current hostname, not for all the tenants).
                ProxyPass /Shibboleth.sso !

                # When a user hits anything at /Shibboleth.sso, that should go through mod_shib
                <Location /Shibboleth.sso>
                    ShibRequestSetting applicationId ${hostname}
                    SetHandler shib
                </Location>

                # Apache ONLY needs to proxy to the app server when a user has succesfully authenticated with the Shibboleth IdP.
                # That has happened when the user ended up at /api/auth/shibboleth/callback .
                # If a user browses directly to this location, we will have stripped any headers he has sent as they are not to be trusted.
                ProxyPass /api/auth/shibboleth/callback balancer://appnodes/api/auth/shibboleth/callback
                
                <Location /api/auth/shibboleth/callback>
                     AuthType shibboleth
                     ShibRequestSetting applicationId ${hostname}
                     ShibRequestSetting requireSession 1
                     ShibUseHeaders On
                     ShibUseEnvironment Off
                     Require valid-user
                </location>
            ",
        }
    }

    # Apply the apache vhosts for all of them
    create_resources(oae::vhost, $shibboleth_hosts)
}
