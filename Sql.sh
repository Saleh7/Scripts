#!/bin/sh
# Download|Create|import Database#
# By Github/Saleh7 #

E=`tput setaf 1`
G=`tput setaf 2`
A=`tput setaf 3`
C=`tput setaf 6`
B=`tput bold`
R=`tput sgr0`
help() {
echo "
 Use: Sql.sh ${E}[OPTION]${R}
   -u,    --username             Enter the Username
   -p,    --password             Enter the Password
   -n,    --namesql              Enter the Name Sql
   -c,    --urlsql               Enter the URL Sql 

 ${C}Example:${R}${G} sudo bash Sql.sh${R} -u root -p saleh -n datab -c https://gist.github.com
"
}

while [ "$1" != "" ]; do
  case "$1" in
    -u  | --username ) user=$2;shift 2;;
    -p  | --password ) pass=$2;shift 2;;
    -n  | --namesql )  sql=$2;shift 2;;
    -c  | --urlsql )   urlsql=$2;shift 2;;
    -h  | --help )     echo "$(help)";
    exit;shift;break;;
  esac
done
if [ -z "$user" ]
then
    echo "+--------------------------+"
    echo "|${b}${A}Enter the Username(root): ${R}|"
    echo "+--------------------------+"
    read input_Username
    user="$input_Username"
fi

if [ -z "$pass" ]
then
    echo "+--------------------------+"
    echo "|${b}${A}Enter the Password(saleh):${R}|"
    echo "+--------------------------+"
    read input_Password
    pass="$input_Password"
fi

if [ -z "$sql" ]
then
    echo "+--------------------------+"
    echo "|${b}${A}Enter the Name Sql(datab):${R}|"
    echo "+--------------------------+"
    read input_Sql
    sql="$input_Sql"
fi

if [ -z "$urlsql" ]
then
    echo "+--------------------------+"
    echo "|${b}${A}Enter the URL Sql ( URL ):${R}|"
    echo "+--------------------------+"
    read input_URL
    urlsql="$input_URL"
fi
# Clear
echo -en "\ec"

# Running
echo "${b}${A}Running Sql.sh...${R}"

echo "+--------------------------+"
echo "|      Update apt-get      |"
echo "+--------------------------+"
apt-get update
# Clear
echo -en "\ec"

echo "+--------------------------+"
echo "|    Download database     |"
echo "+--------------------------+"
git clone $urlsql $sql


echo "+--------------------------+"
echo "|     Create database      |"
echo "+--------------------------+"
echo "create database $sql" | mysql --user=$user --password=$pass
mysql --user=$user --password=$pass $sql < $sql/$sql.sql

echo "${b}${A}done${R}"

exit 0
