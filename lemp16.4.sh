#!/bin/sh
# Auto Install and Setup LEMP #
#Example:sudo bash lemp16.4.sh -p MyPassword

E=`tput setaf 1`
G=`tput setaf 2`
A=`tput setaf 3`
C=`tput setaf 6`
B=`tput bold`
R=`tput sgr0`

help() {
echo "
 ${b}${A}# Auto Install and Setup LEMP #${R}

 ${b}${C}# Nginx - MySQL - PHP - phpMyAdmin #${R}

 Example:${G} sudo bash lemp16.4.sh ${G}-p${R} ${E}MyPassword123@!-${R}
 ${C}Default:${R}${G} sudo bash lemp16.4.sh${R}${C} | Pssword:testT900${R}"
}

while [ "$1" != "" ]; do
  case "$1" in
    -p  | --password ) pass=$2;shift 2;;
    -h  | --help )     echo "$(help)";
    exit;shift;break;;
  esac
done


echo "${b}${A}Running Lemp.sh...${R}"

echo "+-------------------------------------------+"
echo "|                 Update                    |"
echo "+-------------------------------------------+"
echo -ne '#                   (10%)\r'
apt-get -qq update
# Clear
echo -ne '##                  (15%)\r'
sleep 1
echo -en "\ec"



echo "+-------------------------------------------+"
echo "|     Installing expect Get IP IP Server    |"
echo "+-------------------------------------------+"
echo -ne '###                 (20%)\r'
sudo apt-get install curl -y > /dev/null 2>&1
sudo apt-get install expect -y > /dev/null 2>&1
if [ -z "$pass" ]
then
  pass="testT900"
fi
ip=`curl -s https://api.ipify.org`
# Clear
echo -ne '####                (25%)\r'
sleep 1
echo -en "\ec"



echo "+-------------------------------------------+"
echo "|         Installing | Nginx                |"
echo "+-------------------------------------------+"
echo -ne '######              (40%)\r'
sudo apt-get install nginx -y > /dev/null 2>&1
sudo echo 'server {
    listen 80 default_server;
    listen [::]:80 default_server;

    root /var/www;
    index index.php index.html index.htm index.nginx-debian.html;

    server_name '$ip';

    location / {
        try_files $uri $uri/ =404;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php7.0-fpm.sock;
    }

    location ~ /\.ht {
        deny all;
    }
}' > /etc/nginx/sites-available/default
echo -ne '######              (41%)\r'
sudo cat > /var/www/index.html <<END
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<br/>
<a href="http://$ip/info.php">Php - info</a>.<br/>
</body>
</html>
END

sudo cat > /var/www/info.php <<END
<?php
phpinfo();
?>
END
echo -ne '######              (43%)\r'
# Clear
sleep 1
echo -en "\ec"



echo "+-------------------------------------------+"
echo "|       Installing | mysql-server           |"
echo "+-------------------------------------------+"
echo -ne '########            (50%)\r'
echo "mysql-server mysql-server/root_password password $pass" | debconf-set-selections
echo "mysql-server mysql-server/root_password_again password $pass" | debconf-set-selections
sudo apt-get install mysql-server -y > /dev/null 2>&1
echo -ne '#########           (55%)\r'
expsql=$(expect -c '
set timeout 10
spawn mysql_secure_installation

expect "Enter password for user root:"
send "'$pass'\r"

expect "Press y|Y for Yes, any other key for No:"
send "y\r"

expect "Please enter 0 = LOW, 1 = MEDIUM and 2 = STRONG:"
send "2\r"

expect "Change the password for root ? ((Press y|Y for Yes, any other key for No) :"
send "n\r"

expect "Remove anonymous users? (Press y|Y for Yes, any other key for No) :"
send "y\r"

expect "Disallow root login remotely? (Press y|Y for Yes, any other key for No) :"
send "y\r"

expect "Remove test database and access to it? (Press y|Y for Yes, any other key for No) :"
send "y\r"

expect "Reload privilege tables now? (Press y|Y for Yes, any other key for No) :"
send "y\r"

expect eof
')
echo "$expsql" > /dev/null 2>&1
# Clear
echo -ne '#########           (56%)\r'
sleep 1
echo -en "\ec"



echo "+-------------------------------------------+"
echo "|             Installing | PHP              |"
echo "+-------------------------------------------+"
echo -ne '##########          (60%)\r'
sudo apt-get install php-fpm php-mysql php7.0-curl -y > /dev/null 2>&1
sudo sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/' /etc/php/7.0/fpm/php.ini
sudo sed -i 's/;date.timezone =/date.timezone = Europe\/Berlin/' /etc/php/7.0/fpm/php.ini
sudo sed -i 's/max_execution_time = 30/max_execution_time = 300/' /etc/php/7.0/fpm/php.ini
sudo sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 200M/' /etc/php/7.0/fpm/php.ini
sudo sed -i 's/display_errors = Off/display_errors = On/' /etc/php/7.0/fpm/php.ini
echo -ne '##########          (64%)\r'
# Clear
sleep 1
echo -en "\ec"

echo "+-------------------------------------------+"
echo "|       Installing | PhpMyAdmin             |"
echo "+-------------------------------------------+"
echo -ne '############        (70%)\r'
echo "phpmyadmin phpmyadmin/dbconfig-install boolean false" | debconf-set-selections
echo "phpmyadmin phpmyadmin/reconfigure-webserver multiselect none" | debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/admin-pass password $pass" | debconf-set-selections
echo "phpmyadmin phpmyadmin/app-password-confirm password $pass" | debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/app-pass password $pass" | debconf-set-selections
sudo apt-get install phpmyadmin php-mbstring php-gettext -y > /dev/null 2>&1

sudo ln -s /usr/share/phpmyadmin/ /var/www/
# Clear
echo -ne '#############       (74%)\r'
 sleep 1
echo -en "\ec"


# |
echo "+-------------------------------------------+"
echo "|          Restart php7 - nginx             |"
echo "+-------------------------------------------+"
echo -ne '##################  (100%)\r'
sudo service php7.0-fpm restart
sudo service nginx restart
sleep 1
echo -en "\ec"


echo "+-------------------------------------------+"
echo "|    ${b}${A}Finish Auto Install and Setup LEMP${R}     |"
echo "|                                           |"
echo "| Web Site: http://$ip/"
echo "|                                           |"
echo "| Phpmyadmin: http://$ip/phpmyadmin"
echo "| User:${E}root${R} || Pass:${E}$pass${R}"
echo "|                                           |"
echo "| Test PHP:http://$ip/info.php"
echo "|                                           |"
echo "|        ${E}Warning:Delete info.php${R}            |"
echo "|                                           |"
echo "+-------------------------------------------+"

exit 0
