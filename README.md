# Puppet configuration for Sakai OAE

Based on Erik Froese's puppet environment management for Sakai OAE (http://www.github.com/efroese/puppet-oae-example)

# Install

**Note: Still a work in progress.**

Create a new base64 Joyent smart machine, login as admin, and run:

```

# NODE_NAME below represents the name/'certname' of the node within the puppet config. For a different app node, specify a different node name in the .node file

$ curl --insecure https://raw.github.com/mrvisser/puppet-hilary/master/provisioning/app.sh | sh
$ cd puppet-hilary
$ echo $NODE_NAME > .node
$ bin/pull.sh
$ sudo bin/apply.sh
```
