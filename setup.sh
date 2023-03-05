#!/bin/sh

set -ex

[ "$USER" != 'root' ] && echo 'User is not root!' && exit 1

[ "$(hostname)" != 'pluto' ] && echo 'Hostname is not neptune!' && exit 1

apt-get update
apt-get upgrade

apt-get install \
    apache2 \
    composer \
    exim4-daemon-heavy \
    firewalld \
    shellcheck \
    unattended-upgrades \
    vim

apt-get autoremove

sudo -u james git config --global user.name "James Anderson-Pole"
sudo -u james git config --global user.email "smart.ice9799@fastmail.com"
sudo -u james git config --global pull.rebase false

install --backup --compare --verbose --owner=root --group=root --mode=0644 \
    update-exim4.conf.conf \
    /etc/exim4/update-exim4.conf.conf

firewall-cmd --permanent --add-service=http
firewall-cmd --reload
