if [ "$1" = "" ]
then
  echo "Usage: $0 <hostname> <internal ip>"
  exit
fi

if [ "$2" = "" ]
then
  echo "Usage: $0 <hostname> <internal ip>"
  exit
fi

SCRIPT_HOST=$1
SCRIPT_PUPPET_INTERNAL_IP=$2

sudo sed -i '$ a\
$SCRIPT_PUPPET_INTERNAL_IP puppet' /etc/hosts
sudo pkgin -y install ruby18-puppet

cat > /tmp/puppetd.xml <<EOF
<?xml version="1.0"?>
<!DOCTYPE service_bundle SYSTEM "/usr/share/lib/xml/dtd/service_bundle.dtd.1">

<!-- Puppetd Manifest: Luke Kanies - reductivelabs.com -->

<service_bundle type='manifest' name='puppetd'>

<service
name='pkgsrc/puppetd'
type='service'
version='1'>

<create_default_instance enabled='true'/>
<single_instance/>

<dependency name='config-file'
            grouping='require_all'
            restart_on='none'
            type='path'>
    <service_fmri value='file:////opt/local/etc/puppet/puppet.conf'/>
</dependency>

<dependency name='loopback'
            grouping='require_all'
            restart_on='error'
            type='service'>
    <service_fmri value='svc:/network/loopback:default'/>
</dependency>

<dependency name='physical'
            grouping='require_all'
            restart_on='error'
            type='service'>
    <service_fmri value='svc:/network/physical:default'/>
</dependency>

<dependency name='fs-local'
            grouping='require_all'
            restart_on='none'
            type='service'>
    <service_fmri value='svc:/system/filesystem/local'/>
</dependency>

<exec_method
    type='method'
    name='start'
    exec='/opt/local/bin/puppetd'
    timeout_seconds='60'>

    <method_context>
        <method_environment>
            <envvar name='PATH' value='/opt/local/bin:/opt/local/sbin:/usr/bin:/usr/sbin'/>
        </method_environment>
    </method_context>

</exec_method>

<exec_method
    type='method'
    name='stop'
    exec=':kill'
    timeout_seconds='60' />

<exec_method
    type='method'
    name='refresh'
    exec=':kill -HUP'
    timeout_seconds='60' />

<property_group name='application' type='application'>
    <propval name='config_file' type='astring' value='/opt/local/etc/puppet/puppet.conf'/>
</property_group>

<stability value='Unstable' />

<template>
    <common_name>
        <loctext xml:lang='C'>Puppet Client Daemon</loctext>
    </common_name>
    <documentation>
        <manpage title='puppetd' section='1' />
        <doc_link name='reductivelabs.com'
            uri='http://www.reductivelabs.com/projects/puppet' />
    </documentation>
</template>
</service>

</service_bundle>
EOF
sudo mv /tmp/puppetd.xml /opt/local/share/smf/ruby18-puppet/puppetd.xml

svccfg import /opt/local/share/smf/ruby18-puppet/puppetd.xml
sudo svcadm disable puppetd
sudo bash -c 'echo -e [main]\\npluginsync=true\\n[agent]\\nreport=true > /etc/puppet/puppet.conf'
sudo puppet agent --test

echo "Setup complete and cert requested. Sign the cert on the puppet master using 'puppet cert sign', then come back to this machine and run 'sudo puppet agent -t' to apply the puppet config"
