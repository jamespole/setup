#!/bin/sh

set -x

apt-get update
apt-get upgrade

apt-get install vim

apt-get autoremove
