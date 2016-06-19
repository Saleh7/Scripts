#!/bin/bash
# Install Docker on Ubuntu 16.04 ..

echo ""
echo "Running ..."

# Update
sudo apt-get update
echo -en "\ec"

sudo apt-get install apt-transport-https ca-certificates
echo -en "\ec"

sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
echo -en "\ec"

sudo echo "deb https://apt.dockerproject.org/repo ubuntu-xenial main" | sudo tee /etc/apt/sources.list.d/docker.list
echo -en "\ec"


apt-cache policy docker-engine
sudo apt-get update
echo -en "\ec"

# install docker
sudo apt-get install -y docker-engine
echo -en "\ec"

# running
sudo service docker start
