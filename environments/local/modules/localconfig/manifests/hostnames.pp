class localconfig::hostnames {

    # Add a couple of hostnames that can be used as tenants
    host { 'admin.vagrant.oae': ip => '127.0.0.1' }
    host { 'tenant1.vagrant.oae': ip => '127.0.0.1' }
    host { 'tenant2.vagrant.oae': ip => '127.0.0.1' }
    host { 'tenant3.vagrant.oae': ip => '127.0.0.1' }

}

