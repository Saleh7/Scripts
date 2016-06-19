#!/bin/bash
# Install nodejs on Ubuntu 16.04 ..

echo ""
echo "Running ..."

# Update
sudo apt-get update
echo -en "\ec"

sudo apt-get install npm curl nodejs nodejs-legacy -y
echo -en "\ec"

echo ""
echo "done"
echo ""
node -v
