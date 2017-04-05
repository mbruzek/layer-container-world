#!/bin/bash

for num in {26..45}; do
  NAME=container-world-${num}
  juju run --unit containerworld/${num} -- 'echo -n "ubuntu@$(unit-get public-address) $(cat /root/ubuntu_password.txt)"' > ${NAME}
  scp container-world-${num} ubuntu@developer.juju.solutions:/home/ubuntu/domains/developer.juju.solutions/data/
done
