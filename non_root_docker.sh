#!/bin/bash

exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec &> >(tee docker.log) 2>&1
# Everything below will go to the file 'docker.log':

echo     Non-Root Docker Setup
echo This script will restart your system when finished
echo Properly shutdown any wallet you may have running before continuing
read -p "Press any key to start"

sudo su - <<EOF
sudo apt-get update
sudo apt install curl uidmap -y
EOF

curl -fsSL https://get.docker.com/rootless | sh

sudo su - <<EOF
sudo apt install docker.io -y
EOF

systemctl --user start docker
systemctl --user enable docker

sudo su - <<EOF
sudo loginctl enable-linger $(whoami)
sudo usermod -aG docker $USER
sleep 2
reboot
EOF


