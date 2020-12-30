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
  config.vagrant.plugins=["vagrant-vbguest","vagrant-rsync-back"]
  config.vm.synced_folder ".", "/vagrant/#{NAME}", disabled: true,auto_correct:true
  config.vm.provider "virtualbox" do |vb, override|
    vb.memory = "#{MEMORY_LIMIT}"
    vb.cpus   = "#{CORE_LIMIT}"
    # => enable nested virtualization
    vb.customize ["modifyvm", :id, "--nested-hw-virt", "on"]
    override.vm.box = "generic/debian10"
    override.vm.synced_folder ".", "/vagrant/#{NAME}", owner: "vagrant",group: "vagrant", type: "virtualbox"
    override.vm.provision "shell",privileged:true,name:"docker", path: "contrib/vagrant/provision/docker.sh"
    override.vm.provision "shell",privileged:true,name:"lxd", path: "contrib/vagrant/provision/lxd.sh"
    # => forward lxd port
    override.vm.network "forwarded_port", guest: 8443, host: 8443,auto_correct: true
  end
  config.vm.provider 'docker' do |d, override|
    # d.remains_running = true
    d.name = "#{NAME}"
    d.build_dir = 'contrib/vagrant/docker'
    d.has_ssh = true
    d.env = {
      :SSH_USER => 'vagrant',
      :SSH_SUDO => 'ALL=(ALL) NOPASSWD:ALL',
      :LANG     => 'en_US.UTF-8',
      :LANGUAGE => 'en_US:en',
      :LC_ALL   => 'en_US.UTF-8',
      :SSH_INHERIT_ENVIRONMENT => 'true',
    }
    d.create_args = ["--privileged"]
    d.create_args = ["--cpuset-cpus=#{CORE_LIMIT}"]
    d.create_args = ["--memory=#{MEMORY_LIMIT}m"]
    d.volumes=[
      "#{ENV["PWD"]}:/vagrant/#{NAME}/:z",
      # [NOTE] => removes '.vagrant' and '.git' from container
      "vagrant:/vagrant/#{NAME}/.vagrant",
      "git:/vagrant/#{NAME}/.git",
    ]
    override.trigger.after [:resume,:up,:reload] do |t|
      t.info = "Taking ownership of /vagrant directory in the container"
      t.run_remote = {inline: "sudo chown 'vagrant:vagrant' /vagrant -R"}
    end
    override.trigger.before [:suspend,:halt,:destroy] do |t|
      t.info = "Returning ownership of /vagrant directory back to '#{ENV["USER"]}''"
      t.run = {inline: "sudo chown '#{ENV["USER"]}:#{ENV["USER"]}' #{ENV["PWD"]} -R"}
    end
  end
  config.vm.provision "file",source: "contrib/vagrant/bin", destination: "/tmp/bin"
  config.vm.provision "shell",privileged:true,name:"cleanup", inline: $cleanup_script
  config.vm.provision "shell",privileged:false,name:"init", path: "contrib/vagrant/provision/init.sh"
  config.vm.provision "shell",privileged:true,name:"node", path: "contrib/vagrant/provision/node.sh"
  config.vm.provision "shell",privileged:false,name:"python", path: "contrib/vagrant/provision/python.sh"
  config.vm.provision "shell",privileged:false,name:"ansible", path: "contrib/vagrant/provision/ansible.sh"
  config.vm.provision "shell",privileged:false,name:"openstack", path: "contrib/vagrant/provision/openstack.sh"
  config.vm.provision "shell",privileged:false,name:"starship", path: "contrib/vagrant/provision/starship.sh"
  config.vm.provision "shell",privileged:false,name:"nu", path: "contrib/vagrant/provision/nu.sh"
  config.vm.provision "shell",privileged:false,name:"goenv", path: "contrib/vagrant/provision/goenv.sh"
  config.vm.provision "shell",privileged:false,name:"levant", path: "contrib/vagrant/provision/levant.sh"
  config.vm.provision "shell",privileged:false,name:"rbenv", path: "contrib/vagrant/provision/rbenv.sh"
  config.vm.provision "shell",privileged:false,name:"spacevim", path: "contrib/vagrant/provision/spacevim.sh"
  config.vm.provision "shell",privileged:true,name:"hashicorp", path: "contrib/vagrant/provision/hashicorp.sh"
  config.vm.provision "shell",privileged:true,name:"ripgrep", path: "contrib/vagrant/provision/ripgrep.sh"
  config.trigger.after [:provision] do |t|
    t.info = "cleaning up after provisioning"
    t.run_remote = {inline: $cleanup_script }
  end
  # => forward port 8080 in case needed 
  config.vm.network "forwarded_port", guest: 8080, host: 8080,auto_correct: true
end
