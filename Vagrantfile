# -*- mode: ruby -*-
# vi: set ft=ruby :

default_provider = ENV['VAGRANT_DEFAULT_PROVIDER'] || 'virtualbox'
ENV['VAGRANT_DEFAULT_PROVIDER'] = default_provider
NAME=ENV["VAGRANT_MACHINE_NAME"] || File.basename(Dir.pwd)
MEMORY_LIMIT=ENV["MEMORY_LIMIT"] || 4096
CORE_LIMIT=ENV["CORE_LIMIT"] || 4
$cleanup_script = <<-SCRIPT
apt-get autoremove -yqq --purge > /dev/null 2>&1
apt-get autoclean -yqq > /dev/null 2>&1
apt-get clean -qq > /dev/null 2>&1
rm -rf /var/lib/apt/lists/*
SCRIPT
Vagrant.configure("2") do |config|
  config.vm.define "#{NAME}"
  config.vm.hostname = "#{NAME}"
  config.vagrant.plugins=["vagrant-vbguest"]
  config.vm.synced_folder ".", "/vagrant/#{NAME}", disabled: true,auto_correct:true
  config.vm.provider "virtualbox" do |vb, override|
    vb.memory = "#{MEMORY_LIMIT}"
    vb.cpus   = "#{CORE_LIMIT}"
    # => enable nested virtualization
    vb.customize ["modifyvm", :id, "--nested-hw-virt", "on"]
    override.vm.box = "generic/debian10"
    override.vm.synced_folder ".", "/vagrant/#{NAME}", owner: "vagrant",group: "vagrant", type: "virtualbox"
  end
  config.vm.provision "file",source: "contrib/vagrant/bin", destination: "/tmp/bin"
  config.vm.provision "shell",privileged:true,name:"cleanup", inline: $cleanup_script
  config.vm.provision "shell",privileged:false,name:"init", path: "contrib/vagrant/provision/init.sh"
  config.vm.provision "shell",privileged:true,name:"node", path: "contrib/vagrant/provision/node.sh"
  config.vm.provision "shell",privileged:false,name:"python", path: "contrib/vagrant/provision/python.sh"
  config.vm.provision "shell",privileged:false,name:"ansible", path: "contrib/vagrant/provision/ansible.sh"
  config.vm.provision "shell",privileged:false,name:"starship", path: "contrib/vagrant/provision/starship.sh"
  config.vm.provision "shell",privileged:false,name:"nu", path: "contrib/vagrant/provision/nu.sh"
  config.vm.provision "shell",privileged:false,name:"goenv", path: "contrib/vagrant/provision/goenv.sh"
  config.vm.provision "shell",privileged:false,name:"levant", path: "contrib/vagrant/provision/levant.sh"
  config.vm.provision "shell",privileged:false,name:"spacevim", path: "contrib/vagrant/provision/spacevim.sh"
  config.vm.provision "shell",privileged:true,name:"hashicorp", path: "contrib/vagrant/provision/hashicorp.sh"
  config.vm.provision "shell",privileged:true,name:"ripgrep", path: "contrib/vagrant/provision/ripgrep.sh"
  config.vm.provision "shell",privileged:true,name:"docker", path: "contrib/vagrant/provision/docker.sh"
  config.vm.provision "shell",privileged:true,name:"lxd", path: "contrib/vagrant/provision/lxd.sh"
  # => forward lxd port
  config.vm.network "forwarded_port", guest: 8443, host: 8443,auto_correct: true
  config.trigger.after [:provision] do |t|
    t.info = "cleaning up after provisioning"
    t.run_remote = {inline: $cleanup_script }
  end
  # => forward port 8080 in case needed 
  config.vm.network "forwarded_port", guest: 8080, host: 8080,auto_correct: true
end
