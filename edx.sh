#!/bin/sh

echo "| Update |"
sudo apt-get update
echo -en "\ec"

echo "| apt-get install apt-transport-https ca-certificates |"
sudo apt-get install apt-transport-https ca-certificates
echo -en "\ec"

echo "| apt-key |"
sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
echo -en "\ec"

echo "| sources.list.d |"
sudo sh -c "echo deb https://apt.dockerproject.org/repo ubuntu-trusty main > /etc/apt/sources.list.d/docker.list"
echo -en "\ec"

echo "| Update |"
sudo apt-get update
echo -en "\ec"

echo "| lxc-docker |"
sudo apt-get purge lxc-docker
echo -en "\ec"

echo "| docker-engine |"
sudo apt-cache policy docker-engine -y
echo -en "\ec"

echo "| Update |"
sudo apt-get update
echo -en "\ec"

echo "| linux-image-generic-lts-trusty |"
sudo apt-get install linux-image-generic-lts-trusty -y
echo -en "\ec"

echo "| docker-engine |"
sudo apt-get install docker-engine -y
echo -en "\ec"

echo "| dockere |"
sudo service docker start
echo -en "\ec"

echo ":)"
echo "sudo docker run -d -p 18010:18010 -p 80:80 appsembler/edx-full"
echo ":)"
exit 0
