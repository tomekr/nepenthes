#!/bin/bash

PACKAGES="git tmux build-essential libfontconfig1 ruby1.9.1 ruby1.9.1-dev \
  libsqlite3-dev libxslt1-dev nmap nikto openssh-server"

UBUNTU_VERSION=`lsb_release -r -s`

cd /home/vagrant

if [ $UBUNTU_VERSION \< "12.10" ]; then
  echo -e "\n[*] Using Ubuntu < 12.10, downloading PhantomJS separately."
  arch=`uname -m`
  if [[ $arch == "x86_64" ]]; then
    phantomjshash=c78c4037d98fa893e66fc516214499c58228d2f9
  else
    phantomjshash=9ead5dd275f79eaced61ce63dbeca58be4d7f090
  fi
  wget -O phantomjs.tar.bz2 \
    https://phantomjs.googlecode.com/files/phantomjs-1.9.2-linux-$arch.tar.bz2
  sha1sum phantomjs.tar.bz2 | grep -q $phantomjshash
  if [ $? -ne 0 ]; then
    echo "Unexpected PhantomJS SHA-1 hash. Please try again."
    exit 1
  fi
  echo -e "\n[*] Extracting PhantomJS..."
  tar xjf phantomjs.tar.bz2
  echo -e "\n[*] Installing PhantomJS..."
  cp phantomjs-*/bin/phantomjs /bin/
else
  echo -e "\n[*] Using Ubuntu >= 12.10, using the repository's PhantomJS."
  PACKAGES="$PACKAGES phantomjs"
fi

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

echo -e "\n[*] Tidying Nepenthes for remote work"
cp config/database.yml.example config/database.yml
chmod 0777 log
cp config/auth.yml.example config/auth.yml

echo -e "\n[*] Installing Bundler"
gem install --no-rdoc --no-ri bundler

echo -e "\n[*] Installing Nepenthes' required gems"
bundle install --without local

echo -e "\n[*] Dropping Nepenthes worker scripts in ~/"
ln -s `pwd`/script/*worker*.sh ../
chmod +x script/*worker*.sh

echo -e "\n[*] Run ./start-nepenthes-worker.sh to begin."
