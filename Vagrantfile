require 'pry'
# -*- mode: ruby -*-
# vi: set ft=ruby :

# This is the VM image used for all of the machines used by Nepenthes.
#
# https://atlas.hashicorp.com/boxcutter/boxes/ubuntu1604
#
# Also listed are the various configuration constants
NEPENTHES_VM_BOX  = "bento/ubuntu-16.04"
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
  config.vm.box = NEPENTHES_VM_BOX

  # This configuration is for the scanning component of Nepenthes, called a
  # tendril. This is the component that the sprout will connect to and manage.
  config.vm.define "tendril" do |tendril|
    tendril.vm.network "private_network", ip: "192.168.50.3"

    # This script installs and sets up the tendril
    tendril.vm.provision :shell, path: "script/vagrant/vagrant-nepenthes-worker.sh"

    tendril.vm.provider "virtualbox" do |v|
      v.memory = TENDRIL_VM_MEMORY
      v.cpus   = DEFAULT_VM_CORES
    end
  end

  # This configuration is for the management component of Nepenthes, called a
  # spout. This component stores the database, handles user requests, etc.. The
  # commands for scanning individual hosts are then sent off to the tendril.
  config.vm.define "sprout" do |sprout|
    sprout.vm.network "private_network", ip: "192.168.50.2"

    # Here we're forwarding the web server port to 8081 on the host. This means
    # you'll navigate to http://localhost:8081 on your host machine to reach
    # nepenthes
    sprout.vm.network 'forwarded_port', guest: 8080, host: 8081

    # This script installs and sets up the sprout
    sprout.vm.provision :shell, path: "script/vagrant/vagrant-nepenthes-server.sh"

    sprout.vm.provider "virtualbox" do |v|
      v.memory = SPROUT_VM_MEMORY
      v.cpus   = DEFAULT_VM_CORES
    end
  end
end
