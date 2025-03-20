#!/bin/bash
apt -y install gpg acl
mkdir -p /etc/apt/keyrings/
wget -q -O - https://apt.grafana.com/gpg.key | gpg --dearmor |  tee /etc/apt/keyrings/grafana.gpg > /dev/null
echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" |  tee /etc/apt/sources.list.d/grafana.list
 apt-get update &&  apt-get -y install alloy
usermod -aG systemd-journal alloy
setfacl -R -m u:alloy:rX /var/log
setfacl -R -m d:u:alloy:rX /var/log
systemctl start alloy
systemctl enable alloy.service
