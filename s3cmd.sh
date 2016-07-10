#!/bin/sh
# Installation of Amazon S3 Tools s3cmd
# S3cmd : Command Line S3 Client and Backup for Linux and Mac
# http://s3tools.org/s3cmd
#
# https://github.com/Saleh7

#
echo 'update ..'
sudo apt-get -qq update

#
echo 'Import S3tools signing key'
sudo wget -O- -q http://s3tools.org/repo/deb-all/stable/s3tools.key | sudo apt-key add -

#
echo 'Add the repo to sources.list'
sudo wget -O/etc/apt/sources.list.d/s3tools.list http://s3tools.org/repo/deb-all/stable/s3tools.list > /dev/null 2>&1

#
echo 'update ..'
sudo apt-get -qq update

#
echo 'install the newest s3cmd'
sudo apt-get install s3cmd -y > /dev/null 2>&1

#
echo ""
echo "Done! ......"
echo ""
echo "S3cmd usage: http://s3tools.org/usage"
