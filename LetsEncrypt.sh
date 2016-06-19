#!/bin/bash
# Ubuntu 16.04 Let's Encrypt SSL certs

Email=foo@bar.com
Domain=igeek.io
echo ""
echo "Running ..."

# Update
sudo apt-get -qq update

# Install git
sudo apt-get -y install git

# Stop nginx
sudo service nginx stop

# Clone Let's Encrypt
cd ~
sudo git clone https://github.com/letsencrypt/letsencrypt /opt/letsencrypt
cd letsencrypt
sudo ./letsencrypt-auto certonly --standalone --email $Email -d $Domain --agree-tos --text

# Start nginx back up
service nginx start
