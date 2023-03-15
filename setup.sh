#!/usr/bin/env bash

set -ex

expected_hostname='pluto'

[ "${USER}" != 'root' ] && printf 'User is not root!' && exit 1

[ "$(hostname)" != "${expected_hostname}" ] && printf 'Hostname is not %s!' "${expected_hostname}" && exit 1

[ ! -f '/etc/debian_version' ] && printf 'System is not Debian!' && exit 1

timedatectl set-timezone 'Pacific/Auckland'

apt-get update
apt-get upgrade

apt-get install \
    composer \
    exim4-daemon-heavy \
    deborphan \
    lynis \
    mtr \
    samba \
    screen \
    shellcheck \
    subliminal \
    youtube-dl

install='install --backup --compare --verbose --owner=root --group=root --mode=0644'

apt-get install apache2 libapache2-mod-php
a2enmod userdir
apache2ctl configtest

apt-get install bash bash-completion
${install} --owner=james --group=james bash_aliases /home/james/.bash_aliases

apt-get install bind9

apt-get install borgbackup
${install} --owner=james --group=james --mode=0755 borg.sh /home/james/

echo 'pole.net.nz' > /etc/mailname
[ -d /etc/exim4 ] && ${install} update-exim4.conf.conf /etc/exim4

apt-get install git
sudo -u james git config --global user.name 'James Anderson-Pole'
sudo -u james git config --global user.email 'smart.ice9799@fastmail.com'
sudo -u james git config --global pull.rebase false

apt-get install network-manager
cat << EOF > /etc/network/interfaces
auto lo
iface lo inet loopback
EOF
${install} --mode=0600 ORBI82.nmconnection /etc/NetworkManager/system-connections/
${install} --mode=0600 Prodigi.nmconnection /etc/NetworkManager/system-connections/
systemctl enable NetworkManager.service

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

apt-get install fail2ban
${install} default.local /etc/fail2ban/jail.d/

[ "$(systemd-detect-virt)" = 'kvm' ] && apt-get install qemu-guest-additions

apt-get install unattended-upgrades
cat << EOF > /etc/apt/apt.conf.d/99local
Unattended-Upgrade::Automatic-Reboot "true";
Unattended-Upgrade::Mail "james@pole.net.nz";
Unattended-Upgrade::MailReport "always";
EOF

# vim config
apt-get install vim
${install} --owner=james --group=james vimrc /home/james/.vimrc

apt-get install firewalld
firewall-cmd --permanent --add-service={dns,http,https}

apt-get autoremove

[ -f /var/run/reboot-required ] && shutdown -r now && exit

systemctl restart 'networking.service' 'NetworkManager.service' 'ssh.service' 'exim4.service' 'apache2.service' 'fail2ban.service' 'firewalld.service'

ssh-audit --level=warn localhost
