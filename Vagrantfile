require 'pry'
# -*- mode: ruby -*-
# vi: set ft=ruby :

# This is the VM image used for all of the machines used by Nepenthes.
#
# https://atlas.hashicorp.com/boxcutter/boxes/ubuntu1604
#
# Also listed are the various configuration constants
NEPENTHES_VM_BOX      = "ubuntu/trusty64"
#NEPENTHES_VM_BOX      = "boxcutter/ubuntu1604"
#NEPENTHES_VM_BOX_URL  = "https://atlas.hashicorp.com/boxcutter/boxes/ubuntu1604/versions/2.0.23/providers/virtualbox.box"
DEFAULT_VM_MEMORY = 2048
SPROUT_VM_MEMORY  = 2048
TENDRIL_VM_MEMORY = 4096
DEFAULT_VM_CORES  = 1

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  # In multi-machine environments, config is the globally scoped and will be
  # inherited by all VMs
  #config.vm.box = NEPENTHES_VM_BOX
  #config.vm.box = 'ubuntu/xenial64'
  config.vm.box = 'bento/ubuntu-16.04'
  #config.vm.box_version = '>= 20160925.0.0'
  #config.vm.box_url = NEPENTHES_VM_BOX_URL

  # Make the VMs use a bridged connection using DHCP to pick up an IP address.
  # We can then use vagrant's ssh-config command to get the dynamically
  # assigned IPs.
  #config.vm.network "public_network"


  # This configuration is for the scanning component of Nepenthes, called a
  # tendril. This is the component that the sprout will connect to and manage.
  config.vm.define "tendril" do |tendril|
    tendril.vm.network "private_network", ip: "192.168.50.3"
    # This script installs and sets up the tendril
    tendril.vm.provision :shell, path: "script/vagrant/vagrant-nepenthes-worker.sh"

    tendril.vm.provider "virtualbox" do |v|
      v.memory = TENDRIL_VM_MEMORY
      v.cpus = DEFAULT_VM_CORES
    end
  end

  # This configuration is for the management component of Nepenthes, called a
  # spout. This component stores the database, handles user requests, etc.. The
  # commands for scanning individual hosts are then sent off to the tendril.
  config.vm.define "sprout" do |sprout|
    sprout.vm.network "private_network", ip: "192.168.50.2"
    sprout.vm.network 'forwarded_port', guest: 8080, host: 8081
    #sprout.vm.network "forwarded_port", guest: 6397, host_ip: "192.168.50.3", host: 6379
    # This script installs and sets up the sprout
    sprout.vm.provision :shell, path: "script/vagrant/vagrant-nepenthes-server.sh"

    sprout.vm.provider "virtualbox" do |v|
      v.memory = SPROUT_VM_MEMORY
      v.cpus = DEFAULT_VM_CORES
    end
  end

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # config.vm.network "forwarded_port", guest: 80, host: 8080

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  # config.vm.network "private_network", ip: "192.168.33.10"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  # config.vm.provider "virtualbox" do |vb|
  #   # Display the VirtualBox GUI when booting the machine
  #   vb.gui = true
  #
  #   # Customize the amount of memory on the VM:
  #   vb.memory = "1024"
  # end
  #
  # View the documentation for the provider you are using for more
  # information on available options.

  # Define a Vagrant Push strategy for pushing to Atlas. Other push strategies
  # such as FTP and Heroku are also available. See the documentation at
  # https://docs.vagrantup.com/v2/push/atlas.html for more information.
  # config.push.define "atlas" do |push|
  #   push.app = "YOUR_ATLAS_USERNAME/YOUR_APPLICATION_NAME"
  # end

  # Enable provisioning with a shell script. Additional provisioners such as
  # Puppet, Chef, Ansible, Salt, and Docker are also available. Please see the
  # documentation for more information about their specific syntax and use.
  # config.vm.provision "shell", inline: <<-SHELL
  #   apt-get update
  #   apt-get install -y apache2
  # SHELL
end
