class shibboleth::sp (
        # The entity ID of the Shibboleth service provider. e.g.: https://sp.oaeproject.org/shibboleth
        $entity_id,

        # The name of the key that is used. e.g.: web0
        $keyname,

        # The subjectname that is used in the certificate. e.g.: CN=web0
        $subjectname,

        # An object where each value is an object that contains the mapping for the `remote_user` attribute and the `hostname` they will be available at
        $shibboleth_hosts = {},
    ) {

    # Ensure that the required shibboleth packages have been installed
    $shib_packages = ['shibboleth-sp2-schemas', 'libshibsp-dev', 'libshibsp-doc', 'opensaml2-tools', 'libapache2-mod-shib2']
    package { $shib_packages:
        ensure  => installed,
    }

    # Configure the shibboleth SP config
    file { '/etc/shibboleth/shibboleth2.xml':
        ensure  => present,
        content => template('shibboleth/shibboleth2.xml.erb'),
        require => Package[$shib_packages],
    }

    file { '/etc/shibboleth/sp-key.pem':
        ensure  => present,
        content => template('shibboleth/sp-key.pem'),
        require => Package[$shib_packages],
    }

    file { '/etc/shibboleth/sp-cert.pem':
        ensure  => present,
        content => template('shibboleth/sp-cert.pem'),
        require => Package[$shib_packages],
    }

    # A bit of a hack, but our metadata file needs the base64 part of the certicate
    $raw_certificate = template('shibboleth/sp-cert.pem')
    $certificate = inline_template("<%= @raw_certificate.split('-----')[2].strip %>")

    # Generate a metadata file that will contain all our tenant hostnames
    file { '/opt/shibboleth-sp':
        ensure  =>  directory,
    }
    file { '/opt/shibboleth-sp/metadata.xml':
        ensure  => present,
        content => template('shibboleth/metadata-sp.xml.erb'),
        require => File['/opt/shibboleth-sp'],
    }
    file { '/opt/shibboleth-sp/logo.jpg':
        ensure  => present,
        content => template('shibboleth/logo.jpg'),
        require => File['/opt/shibboleth-sp'],
    }
    file { '/opt/shibboleth-sp/main.css':
        ensure  => present,
        content => template('shibboleth/main.css'),
        require => File['/opt/shibboleth-sp'],
    }

    # Ensure that the ukfederation certificate is present
    file { '/etc/shibboleth/ukfederation.cer':
        ensure  => present,
        content => template('shibboleth/ukfederation.cer'),
        require => Package[$shib_packages],
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

    # Apply the apache vhosts for all of the hosts that wish to have shibboleth enabled
    # We need to apply multiple apache::vhost resources. Unfortunately, we can't pass the $shibboleth_hosts
    # object as the namevar AND use the namevar in the parameters (for the `servername` property)
    # That's why we wrap it in our own oae::vhost. This is how we can iterate over the $shibboleth_hosts
    # array AND get the value of the namevar in the properties.
    create_resources(shibboleth::vhost, $shibboleth_hosts)
}
