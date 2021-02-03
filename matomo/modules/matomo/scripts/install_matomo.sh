#!/bin/bash

#set -e -x

# Install HTTPD
yum -y install httpd
yum -y install php
yum install -y oracle-php-release-el7
yum update -y oracle-php-release-el7
yum update -y php
yum install -y install php-json
yum -y install php-pdo
yum -y install php-mysqlnd
yum -y install php-mbstring
yum -y install php-gd
yum -y install php-xml
echo 'extension=dom.so' | sudo tee -a /etc/php.ini

# Download Matomo
wget -O /home/opc/matomo.zip https://builds.matomo.org/matomo.zip

# Unzip Matomo
mkdir /var/www/html/analytics/
unzip -o /home/opc/matomo.zip -d /var/www/html/analytics/

# Fixing privs
chown -R apache:apache /var/www/html/analytics/matomo
find /var/www/html/analytics/matomo/tmp -type f -exec chmod 755 {} \;
find /var/www/html/analytics/matomo/tmp -type d -exec chmod 777 {} \;
mkdir /var/www/html/analytics/matomo/tmp/assets/
chown -R apache:apache /var/www/html/analytics/matomo/tmp/assets/
find /var/www/html/analytics/matomo/tmp/assets/ -type f -exec chmod 755 {} \;
find /var/www/html/analytics/matomo/tmp/assets/ -type d -exec chmod 777 {} \;
mkdir /var/www/html/analytics/matomo/tmp/cache/
chown -R apache:apache /var/www/html/analytics/matomo/tmp/cache/
find /var/www/html/analytics/matomo/tmp/cache/ -type f -exec chmod 755 {} \;
find /var/www/html/analytics/matomo/tmp/cache/ -type d -exec chmod 777 {} \;
mkdir /var/www/html/analytics/matomo/tmp/logs/
chown -R apache:apache /var/www/html/analytics/matomo/tmp/logs/
find /var/www/html/analytics/matomo/tmp/logs/ -type f -exec chmod 755 {} \;
find /var/www/html/analytics/matomo/tmp/logs/ -type d -exec chmod 777 {} \;
mkdir /var/www/html/analytics/matomo/tmp/tcpdf/
chown -R apache:apache /var/www/html/analytics/matomo/tmp/tcpdf/
find /var/www/html/analytics/matomo/tmp/tcpdf/ -type f -exec chmod 755 {} \;
find /var/www/html/analytics/matomo/tmp/tcpdf/ -type d -exec chmod 777 {} \;
mkdir /var/www/html/analytics/matomo/tmp/templates_c/
chown -R apache:apache /var/www/html/analytics/matomo/tmp/templates_c/
find /var/www/html/analytics/matomo/tmp/templates_c/ -type f -exec chmod 755 {} \;
find /var/www/html/analytics/matomo/tmp/templates_c/ -type d -exec chmod 777 {} \;

# Install MySQL Community Edition 8.0
rpm -ivh https://dev.mysql.com/get/mysql80-community-release-$(uname -r | sed 's/^.*\(el[0-9]\+\).*$/\1/')-1.noarch.rpm
yum install -y mysql-shell-${mysql_version} 
mkdir ~${user}/.mysqlsh
cp /usr/share/mysqlsh/prompt/prompt_256pl+aw.json ~${user}/.mysqlsh/prompt.json
echo '{
    "history.autoSave": "true",
    "history.maxSize": "5000"
}' > ~${user}/.mysqlsh/options.json
chown -R ${user} ~${user}/.mysqlsh

# Setup MySQL database for Matomo
mysqlsh --user ${admin_username} --password=${admin_password} --host ${mysql_compute_ip} --sql -e "CREATE DATABASE ${matomo_schema};"
mysqlsh --user ${admin_username} --password=${admin_password} --host ${mysql_compute_ip} --sql -e "CREATE USER ${matomo_username} identified by '${matomo_password}';"
mysqlsh --user ${admin_username} --password=${admin_password} --host ${mysql_compute_ip} --sql -e "GRANT ALL PRIVILEGES ON ${matomo_schema}.* TO ${matomo_username};"

# Disabling SELinux
sed -i.bak 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
setenforce 0

# Start HTTPD
systemctl enable httpd.service
systemctl start httpd.service
systemctl status httpd.service

#firewall-cmd --permanent --zone=public --add-service=http 
#firewall-cmd --permanent --zone=public --add-service=https
#firewall-cmd --reload
systemctl disable firewalld.service
systemctl stop firewalld.service