# -*- mode: ruby -*-
# vi: set ft=ruby :

default_provider = ENV['VAGRANT_DEFAULT_PROVIDER'] || 'virtualbox'
ENV['VAGRANT_DEFAULT_PROVIDER'] = default_provider
NAME=ENV["VAGRANT_MACHINE_NAME"] || File.basename(Dir.pwd)
MEMORY_LIMIT=ENV["MEMORY_LIMIT"] || 4096
CORE_LIMIT=ENV["CORE_LIMIT"] || 4
$cleanup_script = <<-SCRIPT
sudo apt-get autoremove -yqq --purge > /dev/null 2>&1
sudo apt-get autoclean -yqq > /dev/null 2>&1
sudo apt-get clean -qq > /dev/null 2>&1
sudo rm -rf /var/lib/apt/lists/*
SCRIPT
INSTALLER_SCRIPTS_BASE_URL="https://raw.githubusercontent.com/da-moon/provisioner-scripts/master/bash/installer"
UTIL_SCRIPTS_BASE_URL="https://raw.githubusercontent.com/da-moon/provisioner-scripts/master/bash/util"
Vagrant.configure("2") do |config|
  config.vm.define "#{NAME}"
  config.vm.hostname = "#{NAME}"
  config.vagrant.plugins=["vagrant-vbguest"]
  config.vm.synced_folder ".", "/vagrant/#{NAME}", disabled: true,auto_correct:true
  config.vm.provider "virtualbox" do |vb, override|
    vb.memory = "#{MEMORY_LIMIT}"
    vb.cpus   = "#{CORE_LIMIT}"
    # => enable nested virtualization
    vb.customize ["modifyvm",:id,"--nested-hw-virt", "on"]    
    override.vm.box = "generic/debian10"
    override.vm.synced_folder ".", "/vagrant/#{NAME}", owner: "vagrant",group: "vagrant", type: "virtualbox"
  end
  config.vm.provision "shell",privileged:false,name:"cleanup", inline: $cleanup_script
  config.vm.provision "shell",privileged:false,name:"init", path: "#{INSTALLER_SCRIPTS_BASE_URL}/init"
  config.vm.provision "shell",privileged:false,name:"node", path: "#{INSTALLER_SCRIPTS_BASE_URL}/node"
  config.vm.provision "shell",privileged:false,name:"python", path: "#{INSTALLER_SCRIPTS_BASE_URL}/python"
  config.vm.provision "shell",privileged:false,name:"starship", path: "#{INSTALLER_SCRIPTS_BASE_URL}/starship"
  config.vm.provision "shell",privileged:false,name:"nu", path: "#{INSTALLER_SCRIPTS_BASE_URL}/nu"
  config.vm.provision "shell",privileged:false,name:"goenv", path: "#{INSTALLER_SCRIPTS_BASE_URL}/goenv"
  config.vm.provision "shell",privileged:false,name:"spacevim", path: "#{INSTALLER_SCRIPTS_BASE_URL}/spacevim"
  config.vm.provision "shell",privileged:false,name:"hashicorp", path: "#{INSTALLER_SCRIPTS_BASE_URL}/hashicorp"
  config.vm.provision "shell",privileged:false,name:"ripgrep", path: "#{INSTALLER_SCRIPTS_BASE_URL}/ripgrep"
  config.vm.provision "shell",privileged:false,name:"docker", path: "#{INSTALLER_SCRIPTS_BASE_URL}/docker"
  config.vm.provision "shell",privileged:false,name:"lxd", path: "#{INSTALLER_SCRIPTS_BASE_URL}/lxd"
  # => forward lxd port
  config.vm.network "forwarded_port", guest: 8443, host: 8443,auto_correct: true
  # downloading helper executable scripts
  config.vm.provision "shell",privileged:false,name:"utilities", inline: <<-SCRIPT
  [ -r /usr/local/bin/disable-ssh-password-login ] || \
    sudo curl -s \
    -o /usr/local/bin/disable-ssh-password-login \
    #{UTIL_SCRIPTS_BASE_URL}/disable-ssh-password-login && \
    sudo chmod +x /usr/local/bin/disable-ssh-password-login
  [ -r /usr/local/bin/key-get ] || \
    sudo curl -s \
    -o /usr/local/bin/key-get \
    #{UTIL_SCRIPTS_BASE_URL}/key-get && \
    sudo chmod +x /usr/local/bin/key-get
  [ -r /usr/local/bin/lxd-debian ] || \
    sudo curl -s \
    -o /usr/local/bin/lxd-debian \
    #{UTIL_SCRIPTS_BASE_URL}/lxd-debian && \
    sudo chmod +x /usr/local/bin/lxd-debian
  [ -r /usr/local/bin/ngrok-init ] || \
    sudo curl -s \
    -o /usr/local/bin/ngrok-init \
    #{INSTALLER_SCRIPTS_BASE_URL}/ngrok && \
    sudo chmod +x /usr/local/bin/ngrok-init
  SCRIPT
  config.trigger.after [:provision] do |t|
    t.info = "cleaning up after provisioning"
    t.run_remote = {inline: $cleanup_script }
  end
end