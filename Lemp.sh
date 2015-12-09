#!/bin/sh
# Auto Install and Setup LEMP #
# Nginx - MySqlServer - PHP5 - PhpMyAdmin#
# By Github/Saleh7 #
#Example:sudo bash Lemp.sh -p MyPassword

E=`tput setaf 1`
G=`tput setaf 2`
A=`tput setaf 3`
C=`tput setaf 6`
B=`tput bold`
R=`tput sgr0`

help() {
echo " 
 ${b}${A}# Auto Install and Setup LEMP #${R}
 Use: Lemp.sh ${E}[OPTION]${R}
 ${G}-p${R}, --password  Enter the Password MySql
 Example:${G} sudo bash Lemp.sh ${G}-p${R} ${E}Saleh7${R}
 ${C}Default:${R}${G} sudo bash Lemp.sh${R}${C} | Pssword:testT900${R}
"
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
echo "| Update apt-get                            |"
echo "+-------------------------------------------+"
apt-get update
# Clear
echo -en "\ec"



echo "+-------------------------------------------+"
echo "|     Installing                            |"
echo "|    curl | expect                          |"
echo "|    curl - Get IP IPServer | Check Pass    |"
echo "+-------------------------------------------+"
apt-get install curl -y
apt-get install expect -y

if [ -z "$pass" ]
then
  pass="testT900"
fi
ip=`curl -s https://api.ipify.org`
# Clear
sleep 1
echo -en "\ec"



echo "+-------------------------------------------+"
echo "|         Installing | Nginx                |"
echo "|     Setting /home/www to web root         |"
echo "+-------------------------------------------+"
apt-get install nginx -y
sudo mkdir /home/www
rm -fr /etc/nginx/sites-available/default
touch /etc/nginx/sites-available/default
echo 'server {
    listen 80 default_server;
    listen [::]:80 default_server ipv6only=on;

    root /home/www;
    index index.php index.html index.htm;

    server_name $ip;

    location / {
        try_files $uri $uri/ =404;
        autoindex on;
    }

    error_page 404 /404.html;
    error_page 500 502 503 504 /50x.html;
    location = /50x.html {
        root /home/www;
    }

    location ~ \.php$ {
        try_files $uri =404;
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass unix:/var/run/php5-fpm.sock;
        fastcgi_index index.php;
        include fastcgi_params;
    }
}' >> /etc/nginx/sites-available/default
sudo touch /home/www/index.html
cat > /home/www/index.html <<END
<!DOCTYPE html>
<html>
<head>
<title>Welcome to My Site</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>My Site</h1>
<p>/home/www</p>
<p>
<em>Thank you for using Script Lemp.sh.</em>
</p>
</body>
</html>
END

sudo touch /home/www/info.php
cat > /home/www/info.php <<END
<?php
phpinfo();
?>
END
# Clear
sleep 1
echo -en "\ec"



echo "+-------------------------------------------+"
echo "|       Installing | mysql-server           |"
echo "+-------------------------------------------+"
debconf-set-selections <<< "mysql-server mysql-server/root_password password $pass"
debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $pass"
apt-get install mysql-server -y

MySqlInst=$(expect -c '
spawn /usr/bin/mysql_secure_installation
expect "Enter current password for root (enter for none):"
send "'$pass'\r"
expect "Change the root password?"
send "n\r"
expect "Remove anonymous users?"
send "y\r"
expect "Disallow root login remotely?"
send "y\r"
expect "Remove test database and access to it?"
send "y\r"
expect "Reload privilege tables now?"
send "y\r"
expect eof
')
echo "$MySqlInst"
# Clear
sleep 1
echo -en "\ec"



echo "+-------------------------------------------+"
echo "|         Installing | PHP                  |"
echo "| php5-fpm|php5-mysql|php5-mcrypt|php5-curl |"
echo "|                                           |"
echo "|               Setting                     |"
echo "|      upload_max_filesize = 200M           |"
echo "|         cgi.fix_pathinfo=0                |"
echo "|         display_errors = On               |"
echo "+-------------------------------------------+"
apt-get install php5-fpm php5-mysql php5-mcrypt php5-curl -y
sudo sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/' /etc/php5/fpm/php.ini
sudo sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 200M/' /etc/php5/fpm/php.ini
sudo sed -i 's/display_errors = Off/display_errors = On/' /etc/php5/fpm/php.ini
# Clear
sleep 1
echo -en "\ec"



echo "+-------------------------------------------+"
echo "|       Installing | PhpMyAdmin             |"
echo "|           /home/www/mysql                 |"
echo "+-------------------------------------------+"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/reconfigure-webserver multiselect none"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/dbconfig-install boolean true"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/admin-user string $pass"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/admin-pass password $pass"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/app-pass password $pass"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/app-password-confirm password $pass"
apt-get install -y phpmyadmin
sudo ln -s /usr/share/phpmyadmin /home/www/mysql
# Clear
sleep 1
echo -en "\ec"


# | Restart php5 - nginx
sudo service php5-fpm restart
sudo service nginx restart
sleep 1
echo -en "\ec"


echo "+-------------------------------------------+"
echo "|    ${b}${A}Finish Auto Install and Setup LEMP${R}     |"
echo "|                                           |"
echo "| Web Site: http://$ip/"
echo "|                                           |"
echo "| Phpmyadmin: http://$ip/mysql"
echo "| User:${E}root${R} || Pass:${E}$pass${R}"
echo "|                                           |"
echo "| Test PHP:http://$ip/info.php"
echo "|                                           |"
echo "|        ${E}Warning:Delete info.php${R}            |"
echo "|                                           |"
echo "|         ${C}By Saleh Bin Homoud :)${R}            |"
echo "+-------------------------------------------+"

exit 0
