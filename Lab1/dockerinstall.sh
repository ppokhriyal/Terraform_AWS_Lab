#!/bin/bash

#set -x

echo "Updating Ubuntu Reposiroty"
sudo apt update
echo "Installing Software Properties Common"
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
echo "Downloading Docker GPG key"
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
echo "Updating Docker Source Respository"
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
sudo apt update
echo "Installing Docker CE"
apt-cache policy docker-ce
sudo apt install -y docker-ce