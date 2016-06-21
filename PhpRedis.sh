#!/bin/sh
# Install PhpRedis #
# By Github/Saleh7 #

echo "+-------------------------------------------------+"
echo "|  Download https://github.com/phpredis/phpredis  |"
echo "+-------------------------------------------------+"
sudo apt-get install redis-server
# Php 7.0
# git clone -b php7 https://github.com/phpredis/phpredis.git
git clone https://github.com/phpredis/phpredis.git

# Php 7.0
# sudo apt-get install php7.0-dev -y
sudo apt-get install php5-dev -y

cd phpredis && phpize && ./configure && make && make install

echo "extension=redis.so" >> /etc/php5/fpm/php.ini
# Php 7.0
# echo 'extension=redis.so' >> /etc/php/7.0/fpm/php.ini

sudo service php5-fpm restart

# Php 7.0
# service php7.0-fpm restart
sudo service nginx restart

echo "|            Done          |"
exit 0
