#!/bin/bash
source charms.reactive.sh

set -ex

@when_not 'containerworld.ready'
function install() {
  add-apt-repository ppa:ubuntu-lxc/lxd-stable -y -u
  apt-get update -qq
  apt-get dist-upgrade -y
  apt-get install -y docker.io lxd pwgen
  usermod -aG lxd ubuntu
  usermod -aG docker ubuntu
  lxd init --auto
  sudo -H -u ubuntu lxc network create lxdbr0 --force-local || true
  sudo -H -u ubuntu lxc network set lxdbr0 dns.mode dynamic
  sudo -H -u ubuntu lxc network set lxdbr0 ipv4.nat true
  sudo -H -u ubuntu lxc network set lxdbr0 ipv6.address none
  sudo -H -u ubuntu lxc network set lxdbr0 ipv4.address 10.250.0.1/24
  sudo -H -u ubuntu lxc network set lxdbr0 ipv4.dhcp.ranges 10.250.0.2-10.250.0.20
  sed -ie 's/PasswordAuthentication .*/PasswordAuthentication yes/' /etc/ssh/sshd_config
  PASSWORD=$(pwgen -N 1 -1)
  echo "${PASSWORD}" > /root/ubuntu_password.txt
  echo -e "${PASSWORD}\n${PASSWORD}" | passwd ubuntu
  systemctl restart sshd
  status-set 'active' 'Welcome to Container World'
  set_state 'containerworld.ready'
}

reactive_handler_main
