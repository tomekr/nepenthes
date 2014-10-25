# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

# This is pretty much copied straight from the .gitignore file. Might be able
# to just pull these files straight from there.
FILES_TO_IGNORE = [ ".git",
                    "public/assets/",
                    ".bundle",
                    "db/*.sqlite3",
                    "log/*.log",
                    "tmp",
                    ".DS_Store",
                    "Gemfile.lock",
                    "config/auth.yml",
                    "config/database.yml",
                    "config/initializers/secret_token.rb" ]

# The default options include the --delete flag which will delete any generated
# files on the VMs which we don't want
RSYNC_ARGS = ["--verbose", "--archive","-z"]

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.define "tendril" do |tendril|
    # Official Ubuntu Server 14.04 LTS (Trusty Tahr)
    tendril.vm.box = "ubuntu/trusty64"

    # Options for folder syncing. Because the tendril and sprout create files
    # in the app root(e.g. auth.yml, database.yml, etc.), we want to preserve
    # changes on the VM and make the sync one way (from host to VM)
    tendril.vm.synced_folder ".", "/home/vagrant/nepenthes", type: "rsync", rsync__exclude: FILES_TO_IGNORE, rsync__args: RSYNC_ARGS, owner: "root", group: "root"

    # This script installs and sets up the tendril
    tendril.vm.provision :shell, path: "script/vagrant/install-nepenthes-worker-vagrant.sh"

    # Assign a private network static IP in the reserved address space. This is
    # going to allow us to setup up communication between the tendril and
    # sprout
    tendril.vm.network :private_network, ip: "10.11.12.14"

    # Options to add more memory and cpus. You may want to uncomment this and
    # modify accordingly if your machines are running slow.
    #tendril.vm.provider "virtualbox" do |v|
      #v.memory = 1024
      #v.cpus = 2
    #end
  end

  config.vm.define "sprout" do |sprout|
    # Official Ubuntu Server 14.04 LTS (Trusty Tahr)
    sprout.vm.box = "ubuntu/trusty64"

    # Options for folder syncing. Because the tendril and sprouts create files
    # in the app root, we want to preserve changes on the VM and make the sync
    # one way (from host to VM)
    sprout.vm.synced_folder ".", "/home/vagrant/nepenthes", type: "rsync", rsync__exclude: FILES_TO_IGNORE, rsync__args: RSYNC_ARGS, owner: "root", group: "root"

    # This script installs and sets up the sprout
    sprout.vm.provision :shell, path: "script/vagrant/install-nepenthes-server-vagrant.sh"

    # Forwards the port 3000 which is the default port for Rails development
    # enviornments.
    sprout.vm.network :forwarded_port, guest: 3000, host: 3000


    sprout.vm.network :private_network, ip: "10.11.12.15"

    # Options to add more memory and cpus. You may want to uncomment this and
    # modify accordingly if your machines are running slow.
    #sprout.vm.provider "virtualbox" do |v|
      #v.memory = 1024
      #v.cpus = 2
    #end
  end
end
