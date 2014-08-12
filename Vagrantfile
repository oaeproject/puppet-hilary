# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  # Use the "oae" box to host
  config.vm.box = "oae"

  # Forward http traffic
  config.vm.network :forwarded_port, host: 8123, guest: 80

  # Share the backend and front-end code with vagrant.
  # It's assumed that Hilary and 3akai-ux are on the same level as puppet-hilary.
  # Note that puppet will change some files in these directories
  config.vm.synced_folder "../Hilary", "/opt/oae"
  config.vm.synced_folder "../3akai-ux", "/opt/3akai-ux"

  # Run a shell script that will do some basic bootstrapping and finally runs puppet.
  config.vm.provision "shell", run: "always", :path => "provisioning/vagrant/init.sh"

  # Allow us to create symlinks on the FS
  config.vm.provider :virtualbox do |vb|
    vb.customize ["setextradata", :id, "VBoxInternal2/SharedFoldersEnableSymlinksCreate/v-root", "1"]
    vb.customize ["modifyvm", :id, "--memory", 3072]
  end

end
