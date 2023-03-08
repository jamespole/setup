#!/bin/sh

borg create \
    --compression auto,lz4 \
    --list \
    --remote-path=borg1 \
    --stats \
    --verbose \
    'sd1031@sd1031.rsync.net:backup::{hostname}-{user}-{now}' \
    ~
