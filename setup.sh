#!/bin/sh

set -x

apt-get update
apt-get upgrade

apt-get install \
    apache2 \
    firewalld \
    shellcheck \
    vim

apt-get autoremove

sudo -u james git config --global user.name "James Anderson-Pole"
sudo -u james git config --global user.email "smart.ice9799@fastmail.com"
sudo -u james git config --global pull.rebase false
