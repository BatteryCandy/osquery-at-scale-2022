#!/bin/bash
set -e

#update /etc/security/limits.conf
echo "root soft nofile 65536
root hard nofile 65536
* soft nofile 65536
* hard nofile 65536" | sudo tee -a /etc/security/limits.conf > /dev/null

#update /etc/sysctl.conf
echo "net.core.somaxconn = 1024
net.core.netdev_max_backlog = 5000
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.ipv4.tcp_wmem = 4096 12582912 16777216
net.ipv4.tcp_rmem = 4096 12582912 16777216
net.ipv4.tcp_max_syn_backlog = 8096
net.ipv4.tcp_slow_start_after_idle = 0
net.ipv4.tcp_tw_reuse = 1
net.ipv4.ip_local_port_range = 10240 65535" | sudo tee -a /etc/sysctl.conf > /dev/null

#copy fluent-bit config
sudo cp /tmp/etc/fluent-bit/fluent-bit.conf /etc/fluent-bit/fluent-bit.conf

#move osquery configs & set logrotate
sudo rsync -av --delete /tmp/etc/osquery/ /etc/osquery
sudo cp /tmp/etc/logrotate/osquery /etc/logrotate.d/

#start fluent-bit and osquery
sudo systemctl enable osqueryd.service
sudo systemctl enable fluent-bit.service
