#!/bin/sh

set -ex

expected_hostname='pluto'

[ "${USER}" != 'root' ] && echo 'User is not root!' && exit 1

[ "$(hostname)" != "${expected_hostname}" ] && echo "Hostname is not ${expected_hostname}!" && exit 1

timedatectl set-timezone 'Pacific/Auckland'

apt-get update
apt-get upgrade

apt-get install \
    composer \
    deborphan \
    screen \
    shellcheck \
    subliminal \
    youtube-dl

install='install --backup --compare --verbose --owner=root --group=root --mode=0644'

# apache2 config
apt-get install apache2 libapache2-mod-php
a2enmod userdir
apache2ctl configtest
systemctl restart apache2.service

# bash config
apt-get install bash bash-completion
${install} --owner=james --group=james bash_aliases /home/james/.bash_aliases

# borgbackup config
apt-get install borgbackup
${install} --owner=james --group=james --mode=0755 borg.sh /home/james/

# exim4 config
apt-get install exim4-daemon-heavy
${install} mailname /etc
${install} update-exim4.conf.conf /etc/exim4
systemctl restart exim4.service

# git config
apt-get install git
sudo -u james git config --global user.name 'James Anderson-Pole'
sudo -u james git config --global user.email 'smart.ice9799@fastmail.com'
sudo -u james git config --global pull.rebase false

# network-manager config
apt-get install network-manager
${install} --mode=0600 ORBI82.nmconnection /etc/NetworkManager/system-connections/
${install} --mode=0600 Prodigi.nmconnection /etc/NetworkManager/system-connections/
systemctl enable NetworkManager.service
systemctl restart NetworkManager.service

# openssh-client config
apt-get install openssh-client
key_path='/home/james/.ssh/id_ed25519'
[ ! -f "${key_path}" ] && sudo -u james ssh-keygen -f "${key_path}" -t ed25519
sudo -u james wget -O '/home/james/.ssh/authorized_keys' -- 'https://github.com/jamespole.keys'

# openssh-server config
apt-get install openssh-server ssh-audit
${install} local.conf /etc/ssh/sshd_config.d/
${install} ssh-audit_hardening.conf /etc/ssh/sshd_config.d/
sshd -t
systemctl restart 'ssh.service'
ssh-audit --level=warn localhost

# [needs openssh-server]
# fail2ban config
apt-get install fail2ban
${install} default.local /etc/fail2ban/jail.d/
systemctl restart 'fail2ban.service'

# unattended-upgrades config
apt-get install unattended-upgrades
${install} 99local /etc/apt/apt.conf.d

# vim config
apt-get install vim
${install} --owner=james --group=james vimrc /home/james/.vimrc

apt-get autoremove

# [last]
# firewalld config
apt-get install firewalld
firewall-cmd --permanent --add-service=http
systemctl restart 'firewalld.service'
