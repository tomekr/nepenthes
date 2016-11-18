#!/bin/bash

if [ "$(id -u)" != "0" ]; then
  echo "Please run this script as root." 1>&2
  exit 1
fi

# Based on confirmation code from http://stackoverflow.com/a/3232082
echo "You are currently in ($(pwd)) on ($(hostname))."

PACKAGES="git tmux build-essential mysql-server redis-server \
  libmysqlclient-dev"

UBUNTU_VERSION=`lsb_release -r -s`

if [ $UBUNTU_VERSION \< "14.04" ]; then
  echo -e "\n[*] Using Ubuntu < 14.04, forcing Ruby 1.9.1"
  PACKAGES="$PACKAGES ruby1.9.1 ruby1.9.1-dev"
else
  echo -e "\n[*] Using Ubuntu >= 14.04, using default Ruby"
  PACKAGES="$PACKAGES ruby ruby-dev"
fi

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
apt-get -qq update

echo -e "\n[*] Installing packages ($PACKAGES)"
apt-get -q install -y $PACKAGES

if [ -e nepenthes ]; then
  echo -e "\n[*] Removing old nepenthes."
  rm -Rf nepenthes
fi

echo -e "\n[*] Fetching Nepenthes"
git clone https://github.com/aschmitz/nepenthes.git
cd nepenthes

echo -e "\n[*] Installing Bundler"
gem install --no-rdoc --no-ri bundler

echo -e "\n[*] Installing Nepenthes' required gems"
bundle install --quiet --without remote

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
RAILS_ENV=production bundle exec rake -s assets:precompile

echo -e "\n[*] Setting up database"
RAILS_ENV=production rake -s db:setup

echo -e "\n[*] Dropping Nepenthes server scripts in ~/"
ln -s `pwd`/script/*server*.sh ../
chmod +x script/*server*.sh

echo -e "\n*************************************************************\n\n" \
  "Vagrant has completed setting up you environment!\n\n" \
  "Now you can run the following commands to get things started:\n" \
  "    1. From your host machine, run \`vagrant ssh sprout\` to log into the sprout VM\n" \
  "    2. Within the sprout VM run \`sudo ./start-nepenthes-server.sh\`\n" \
  "    3. Then \`ssh -R 127.0.0.1:6379:127.0.0.1:6379 vagrant@192.168.50.3\`. This will log you into the tendril VM. Use the password \"vagrant\"\n" \
  "    4. From the tendril VM run \`sudo ./start-nepenthes-worker.sh\`\n" \
  "    5. Optionally run  \`sudo ./watch-nepenthes-worker.sh\` to monitor the worker logs\n" \
  "    6. On your host machine, navigate to http://localhost:8081\n" \
  "    7. Log in with the following credentials (SAVE THESE):\n" \
  "        Username: netpen\n         Password: $NEPENTHES_PASS\n\n" \
  "\n*************************************************************\n\n"
