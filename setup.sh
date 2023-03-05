#!/bin/sh

set -x

apt-get update
apt-get upgrade

apt-get install \
    firewalld \
    shellcheck \
    vim

apt-get autoremove
