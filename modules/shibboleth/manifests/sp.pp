class shibboleth::sp (
        # The entity ID of the Shibboleth service provider. e.g.: https://sp.oaeproject.org/shibboleth
        $entity_id,

        # The name of the key that is used. e.g.: web0
        $keyname,

        # The subjectname that is used in the certificate. e.g.: CN=web0
        $subjectname,

        # The hostname the shibboleth SP is available
        $shibboleth_sp_host,
    ) {

    # Ensure that the required shibboleth packages have been installed
    package { 'shibboleth':
        ensure  => '2.5.3-0switchaai1',
    }

    # Configure the shibboleth SP config
    file { '/etc/shibboleth/shibboleth2.xml':
        ensure  => present,
        content => template('shibboleth/shibboleth2.xml.erb'),
        require => Package['shibboleth'],
    }

    # Configure the Shibboleth SP key
    file { '/etc/shibboleth/sp-key.pem':
        ensure  => present,
        source  => 'puppet:///modules/shibboleth/sp-key.pem',
        require => Package['shibboleth'],
    }
    file { '/etc/shibboleth/sp-cert.pem':
        ensure  => present,
        source  => 'puppet:///modules/shibboleth/sp-cert.pem',
        require => Package['shibboleth'],
    }

    # Put the certificates in place required to trust federation metadata
    file { '/etc/shibboleth/federations':
        source  => 'puppet:///modules/shibboleth/federations',
        recurse => true,
        require => Package['shibboleth'],
    }

    # Configure some error styling
    file { '/usr/share/doc/shibboleth/logo.jpg':
        ensure  => present,
        source  => "puppet:///modules/shibboleth/logo.jpg",
        require => Package['shibboleth'],
    }
    file { '/usr/share/doc/shibboleth/main.css':
        ensure  => present,
        source  => "puppet:///modules/shibboleth/main.css",
        require => Package['shibboleth'],
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

    # Enable the ssl module
    include apache::mod::ssl

    # Enable the proxy modules
    include apache::mod::proxy
    include apache::mod::proxy_http
    include apache::mod::proxy_balancer

    # Add a virtual host that takes care of all the proxying and shib protection
    apache::vhost { $shibboleth_sp_host:
        port => '8080',

        # We need to pass the url the user arrived at
        servername => "https://$shibboleth_sp_host",

        # Unfortunately, the `docroot` parameter is required by the apache::vhost module
        # It's not exposed to users anywhere though
        docroot => '/opt/3akai-ux',

        # apache::vhost's other parameters have some support for proxy passing and Location blocks
        # but not in the way we need it. Therefor we use a custom fragment
        custom_fragment => template('shibboleth/apache_vhost.erb'),
    }
}
