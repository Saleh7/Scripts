#!/bin/sh
# Install PhpRedis #
# By Github/Saleh7 #


echo "+-------------------------------------------------+"
echo "|  Download https://github.com/phpredis/phpredis  |"
echo "+-------------------------------------------------+"
git https://github.com/phpredis/phpredis.git

sudo apt-get install php5-dev -y

cd phpredis && phpize && ./configure && make && make install

sudo sed -i ';   extension=modulename.extension/extension = redis.so/' /etc/php5/fpm/php.ini

sudo service php5-fpm restart
sudo service nginx restart

echo "+--------------------------+"
echo "|            Done          |"
echo "+--------------------------+"
exit 0
