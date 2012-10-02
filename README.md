# Puppet configuration for Sakai OAE

Based on Erik Froese's puppet environment management for Sakai OAE (http://www.github.com/efroese/puppet-oae-example)

# Install

**Note: Still a work in progress.**

Create a new base64 Joyent smart machine, login as admin, and run:

```
$ curl --insecure https://raw.github.com/mrvisser/puppet-hilary/master/init.sh | sh
$ git clone http://www.github.com/mrvisser/puppet-hilary
$ cd puppet-hilary
$ echo "performance" >> .environment
$ echo "app0" >> .node
$ bin/pull.sh
$ sudo bin/apply.sh
```



