#!/bin/sh
#################################################################################
# Ubuntu 14.04 LTS Server                                                       #
# Automated Bash script install and configure / Postfix / Dovecot / with mysql  #
# By https://github.com/Saleh7                                                  #
#################################################################################

# Edit here ..
mysqlPass='PasswordRoot'     # mysql root password here

database="email_server"      # name database email
dbUser="user_db"             # user database email
dbUserPass="pass_user_db"    # password user database email

Domain="example.com"         # your Domain
Email="saleh@example.com"    # Email with your domain
EmailPass="password4email"   # password email
#
# update your system's package list
#
echo 'update your system ..'
apt-get -qq update
echo "+-----------------------------+"

#
# Installing mysql with the root password set to $mysqlPass
#
echo "mysql-server mysql-server/root_password password $mysqlPass" | debconf-set-selections
echo "mysql-server mysql-server/root_password_again password $mysqlPass" | debconf-set-selections
echo 'Installing mysql ..'
sudo apt-get install mysql-server -y > /dev/null 2>&1
sudo apt-get install mysql-client expect -y > /dev/null 2>&1
echo "+-----------------------------+"

#
# running mysql_secure_installation
#
echo 'running mysql_secure_installation ..'
installationMySql=$(expect -c '
spawn /usr/bin/mysql_secure_installation
expect "Enter current password for root (enter for none):"
send "'$mysqlPass'\r"
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
echo "$installationMySql" > /dev/null 2>&1
echo "+-----------------------------+"

#
# Installing postfix - postfix-mysql
#
echo 'Installing postfix ..'
echo "postfix postfix/main_mailer_type string 'Internet Site'" | debconf-set-selections
echo "postfix postfix/mailname string $Domain" | debconf-set-selections
sudo apt-get install postfix -y > /dev/null 2>&1
sudo apt-get install postfix-mysql -y > /dev/null 2>&1
echo "+-----------------------------+"
#
# Installing dovecot-core dovecot-imapd dovecot-pop3d dovecot-lmtpd dovecot-mysql
#
echo 'Installing dovecot ..'
echo "dovecot-core dovecot-core/create-ssl-cert boolean true" | debconf-set-selections
echo "dovecot-core dovecot-core/ssl-cert-name string 'localhost'" | debconf-set-selections
sudo apt-get install dovecot-core dovecot-imapd dovecot-pop3d dovecot-lmtpd dovecot-mysql -y > /dev/null 2>&1
echo "+-----------------------------+"

#
# Create Database and add domain - email
#
createDB(){
    cat <<EOF | mysql -uroot -p$mysqlPass
    CREATE DATABASE IF NOT EXISTS $database;
    GRANT SELECT ON $database.* TO '$dbUser'@'127.0.0.1' IDENTIFIED BY '$dbUserPass';
    FLUSH PRIVILEGES;
    USE $database;

    CREATE TABLE IF NOT EXISTS $database.domains (
    id  INT NOT NULL AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL,
    PRIMARY KEY (id)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8;

    CREATE TABLE IF NOT EXISTS $database.users (
    id INT NOT NULL AUTO_INCREMENT,
    domain_id INT NOT NULL,
    password VARCHAR(106) NOT NULL,
    email VARCHAR(120) NOT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY email (email),
    FOREIGN KEY (domain_id) REFERENCES domains(id) ON DELETE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8;

    CREATE TABLE IF NOT EXISTS $database.aliases (
    id INT NOT NULL AUTO_INCREMENT,
    domain_id INT NOT NULL,
    source varchar(100) NOT NULL,
    destination varchar(100) NOT NULL,
    PRIMARY KEY (id),
    FOREIGN KEY (domain_id) REFERENCES domains(id) ON DELETE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8;

    INSERT INTO $database.domains
    (id ,name)
    VALUES
    ('1', '$Domain');

    INSERT INTO $database.users
    (id, domain_id, password , email)
    VALUES
    ('1', '1', MD5('$EmailPass'), '$Email');
EOF
}
echo 'Create Database ..'
createDB
echo "+-----------------------------+"

#
# Configure postfix main.cf config
#
echo 'Configure postfix main.cf'
postconf -e 'smtpd_recipient_restrictions = permit_sasl_authenticated, permit_mynetworks, reject_unauth_destination'
postconf -e 'smtpd_sasl_auth_enable = yes'
postconf -e 'smtpd_sasl_path = private/auth'
postconf -e 'smtpd_sasl_type = dovecot'
postconf -e 'mydestination = localhost'
postconf -e "myhostname=`hostname`"
postconf -e 'virtual_transport = lmtp:unix:private/dovecot-lmtp'
postconf -e 'virtual_mailbox_domains = mysql:/etc/postfix/mysql-mailbox-domains.cf'
postconf -e 'virtual_mailbox_maps = mysql:/etc/postfix/mysql-mailbox-maps.cf'
postconf -e 'virtual_alias_maps = mysql:/etc/postfix/mysql-alias-maps.cf'
echo "+-----------------------------+"

#
# Connecting Postfix to the database
#
echo 'Configure Postfix database'
echo "user = $dbUser
password = $dbUserPass
hosts = 127.0.0.1
dbname = $database
query = SELECT 1 FROM domains WHERE name='%s'
" > /etc/postfix/mysql-mailbox-domains.cf

echo "user = $dbUser
password = $dbUserPass
hosts = 127.0.0.1
dbname = $database
query = SELECT 1 FROM users WHERE email='%s'
" > /etc/postfix/mysql-mailbox-maps.cf

echo "user = $dbUser
password = $dbUserPass
hosts = 127.0.0.1
dbname = $database
query = SELECT destination FROM aliases WHERE source='%s'
" > /etc/postfix/mysql-alias-maps.cf
echo "+-----------------------------+"

#
# Configure postfix master.cf config
#
echo 'Configure postfix master.cf ..'
postconf -M submission/inet="submission       inet       n       -       -       -       -       smtpd"
postconf -P submission/inet/syslog_name=postfix/submission
postconf -P submission/inet/smtpd_tls_security_level=may
postconf -P submission/inet/smtpd_sasl_auth_enable=yes
postconf -P submission/inet/smtpd_client_restrictions=permit_sasl_authenticated,reject
echo "+-----------------------------+"

#
# Configure mail location
#
echo 'Configure mail location ..'
sudo sed -i '/\!include conf\.d\/\*\.conf/s/^#//' /etc/dovecot/dovecot.conf
echo "protocols = imap lmtp pop3" >> /etc/dovecot/dovecot.conf
sudo sed -i 's/#mail_location = mbox:~\/mail:INBOX=\/var\/mail\/%u/mail_location = maildir:\/var\/mail\/vhosts\/%d\/%n/' /etc/dovecot/conf.d/10-mail.conf
sudo sed -i 's/#mail_privileged_group =/mail_privileged_group = mail/' /etc/dovecot/conf.d/10-mail.conf
echo "+-----------------------------+"

#
# Add mailuser "vmail"
#
echo 'Add mailuser vmail ..'
mkdir -p /var/mail/vhosts/"$Domain"
groupadd -g 5000 vmail
useradd -g vmail -u 5000 vmail -d /var/mail
chown -R vmail:vmail /var/mail
echo "+-----------------------------+"

#
# Configuration file /etc/dovecot/conf.d/10-auth.conf
#
echo 'Configuration 10-auth.conf ..'
sudo sed -i 's/auth_mechanisms = plain/auth_mechanisms = plain login/' /etc/dovecot/conf.d/10-auth.conf
sed -i '/\!include auth-system\.conf\.ext/s/^/#/g' /etc/dovecot/conf.d/10-auth.conf
sed -i '/\!include auth-sql\.conf\.ext/s/^#//g' /etc/dovecot/conf.d/10-auth.conf
echo "passdb {
  driver = sql
  args = /etc/dovecot/dovecot-sql.conf.ext
}
userdb {
  driver = static
  args = uid=vmail gid=vmail home=/var/mail/vhosts/%d/%n
}
" > /etc/dovecot/conf.d/auth-sql.conf.ext
echo "+-----------------------------+"

#
# Authenticate using SQL database
#
echo 'Authenticate database ..'
sudo sed -i 's/#driver =/driver = mysql/' /etc/dovecot/dovecot-sql.conf.ext
sudo sed -i 's/#connect =/connect = host=127.0.0.1 dbname='$database' user='$dbUser' password='$dbUserPass'/' /etc/dovecot/dovecot-sql.conf.ext
sudo sed -i 's/#default_pass_scheme = MD5/default_pass_scheme = MD5/' /etc/dovecot/dovecot-sql.conf.ext
sed -i '/^password_query =.*/s/^/#/g' /etc/dovecot/dovecot-sql.conf.ext
echo "password_query = SELECT email as user, password FROM users WHERE email='%u';" >> /etc/dovecot/dovecot-sql.conf.ext
echo "+-----------------------------+"

#
chown -R vmail:dovecot /etc/dovecot
chmod -R o-rwx /etc/dovecot

#
# Configure Dovecot Master
#
echo "service imap-login {
  inet_listener imap {
    port = 0
  }
  inet_listener imaps {
    #port = 993
    #ssl = yes
  }
}
service pop3-login {
  inet_listener pop3 {
    #port = 110
  }
  inet_listener pop3s {
    #port = 995
    #ssl = yes
  }
}

service lmtp {
  unix_listener /var/spool/postfix/private/dovecot-lmtp {
   mode = 0600
   user = postfix
   group = postfix
  }
}

service imap {
}

service pop3 {
}

service auth {
  unix_listener /var/spool/postfix/private/auth {
    mode = 0666
    user = postfix
    group = postfix
  }

  unix_listener auth-userdb {
   mode = 0600
   user = vmail
   #group =
  }
  # Auth process is run as this user.
  user = dovecot
}

service auth-worker {
  user = vmail
}

service dict {
  unix_listener dict {
  }
}" > /etc/dovecot/conf.d/10-master.conf

#
# Restart postfix - dovecot
#
service postfix restart
service dovecot restart
echo "+-----------------------------------------+"
echo ""
echo "    Email: $Email"
echo "    test send email: https://emkei.cz"
echo "    To list the mail queue: 'postqueue -p'"
echo "    Read Email: 'postcat -q MESSAGE_ID'"
echo ""
echo "+-----------------------------------------+"
echo ""
echo "Done! ......"
