#!/bin/sh

sudo /opt/ruby/bin/puppet apply \
    --verbose \
    --debug \
    --modulepath environments/local/modules:modules \
    --certname dev \
    --environment local \
    --detailed-exitcodes \
    --hiera_config provisioning/vagrant/hiera.yaml \
    site.pp