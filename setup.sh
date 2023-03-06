#!/bin/sh

set -ex

expected_hostname='pluto'

[ "$USER" != 'root' ] && echo 'User is not root!' && exit 1

[ "$(hostname)" != "${expected_hostname}" ] && echo "Hostname is not ${expected_hostname}!" && exit 1

apt-get update
apt-get upgrade

apt-get install \
    borgbackup \
    composer \
    deborphan \
    screen \
    shellcheck \
    subliminal \
    vim \
    youtube-dl

install='install --backup --compare --verbose --owner=root --group=root --mode=0644'

# apache2 config
apt-get install apache2
a2enmod userdir
apache2ctl configtest
systemctl restart apache2.service

# exim4 config
apt-get install exim4-daemon-heavy
${install} mailname /etc
${install} update-exim4.conf.conf /etc/exim4
systemctl restart exim4.service

# git config
apt-get install git
sudo -u james git config --global user.name "James Anderson-Pole"
sudo -u james git config --global user.email "smart.ice9799@fastmail.com"
sudo -u james git config --global pull.rebase false

# openssh-client config
apt-get install openssh-client
key_path='/home/james/.ssh/id_ed25519'
[ ! -f ${key_path} ] && sudo -u james ssh-keygen -f ${key_path} -t ed25519
sudo -u james wget -O "/home/james/.ssh/authorized_keys" -- "https://github.com/jamespole.keys"

# unattended-upgrades config
apt-get install unattended-upgrades
${install} 99local /etc/apt/apt.conf.d

apt-get autoremove

# [last] firewalld config
apt-get install firewalld
firewall-cmd --permanent --add-service=http
systemctl restart firewalld.service
