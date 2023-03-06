#!/bin/sh

set -ex

[ "$USER" != 'root' ] && echo 'User is not root!' && exit 1

[ "$(hostname)" != 'pluto' ] && echo 'Hostname is not neptune!' && exit 1

apt-get update
apt-get upgrade

apt-get install \
    apache2 \
    borgbackup \
    composer \
    deborphan \
    exim4-daemon-heavy \
    firewalld \
    shellcheck \
    unattended-upgrades \
    vim

apt-get autoremove

install='install --backup --compare --verbose --owner=root --group=root --mode=0644'

# apache2 config
a2enmod userdir

# exim4 config
${install} mailname /etc
${install} update-exim4.conf.conf /etc/exim4

# firewalld config
firewall-cmd --permanent --add-service=http

# git config
sudo -u james git config --global user.name "James Anderson-Pole"
sudo -u james git config --global user.email "smart.ice9799@fastmail.com"
sudo -u james git config --global pull.rebase false

# openssh-client config
key_path='/home/james/.ssh/id_ed25519'
[ ! -f ${key_path} ] && sudo -u james ssh-keygen -f ${key_path} -t ed25519
sudo -u james wget -O "/home/james/.ssh/authorized_keys" -- "https://github.com/jamespole.keys"

# unattended-upgrades config
${install} 99local /etc/apt/apt.conf.d

# restart all services except firewalld
systemctl restart apache2.service exim4.service

# restart firewalld last
systemctl restart firewalld.service
