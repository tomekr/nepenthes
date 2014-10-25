#!/bin/bash

PACKAGES="git tmux build-essential ruby1.9.1 ruby1.9.1-dev mysql-server \
  redis-server libmysqlclient-dev"

cd /home/vagrant

echo -e "\n[*] Setting root MySQL password to 'root'."
echo "Do not expose this MySQL to the Internet."
echo "mysql-server-5.5 mysql-server/root_password password root" | \
  debconf-set-selections
echo "mysql-server-5.5 mysql-server/root_password_again password root" | \
  debconf-set-selections

echo -e "\n[*] Checking multiverse availability"
grep -q '^\s*deb.*multiverse' /etc/apt/sources.list
if [ $? -ne 0 ]; then
  echo "No multiverse, backing up /etc/apt/sources.list and adding it."
  cp /etc/apt/sources.list /etc/apt/sources.list.pre-nepenthes
  echo "deb http://archive.ubuntu.com/ubuntu `lsb_release -c -s`" \
    "multiverse" >> /etc/apt/sources.list
  echo -n "deb http://archive.ubuntu.com/ubuntu `lsb_release -c -s`-updates" \
    "multiverse" >> /etc/apt/sources.list
else
  echo "Multiverse appears to be enabled."
fi

echo -e "\n[*] Updating Ubuntu package information cache"
apt-get update

echo -e "\n[*] Installing packages ($PACKAGES)"
apt-get install -y $PACKAGES

# XXX This shouldn't be necessary as vagrant will first sync the nepenthes
# folder to the VM

#if [ -e nepenthes ]; then
  #echo -e "\n[*] Removing old nepenthes."
  #rm -Rf nepenthes
#fi

#echo -e "\n[*] Fetching Nepenthes"
#git clone https://github.com/aschmitz/nepenthes.git

cd nepenthes

echo -e "\n[*] Installing Bundler"
gem install --no-rdoc --no-ri bundler

echo -e "\n[*] Installing Nepenthes' required gems"
bundle install --without remote

echo -e "\n[*] Setting a session secret"
echo "Nepenthes::Application.config.secret_token = \"`rake secret`\"" > \
  config/initializers/secret_token.rb

echo -e "\n[*] Generating auth.yml"
NEPENTHES_PASS=$(openssl rand -base64 6 | tr -dc A-Z-a-z-0-9)
echo -e "username: netpen\npassword: $NEPENTHES_PASS\nchanged: true" > \
  config/auth.yml

echo -e "\n[*] Setting up database.yml"
echo -e "production:\n  adapter: mysql2\n  encoding: utf8\n" \
  " database: netpen\n  username: root\n  password: root" > config/database.yml

echo -e "\n[*] Precompiling assets"
RAILS_ENV=production bundle exec rake assets:precompile

echo -e "\n[*] Setting up database"
RAILS_ENV=production rake db:setup

echo -e "\n[*] Dropping Nepenthes server scripts in ~/"
ln -s `pwd`/script/*server*.sh ../
chmod +x script/*server*.sh

echo -e "\n[*] Your Nepenthes credentials (SAVE THESE):\nUsername:" \
  "netpen\nPassword: $NEPENTHES_PASS"

echo -e "\n[*] Run ./start-nepenthes-server.sh to begin."
