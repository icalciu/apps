#!/bin/bash

configure_redis() {
  echo "vm.overcommit_memory=1" >> /etc/sysctl.conf
  sysctl vm.overcommit_memory=1
  echo never > /sys/kernel/mm/transparent_hugepage/enabled
  echo 1024 > /proc/sys/net/core/somaxconn
}

[ `whoami` = root ] || exec su -c $0 root
configure_redis
