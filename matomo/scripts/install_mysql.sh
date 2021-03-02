#!/bin/bash

#set -e -x


# Install MySQL Community Edition 8.0
rpm -ivh https://dev.mysql.com/get/mysql80-community-release-$(uname -r | sed 's/^.*\(el[0-9]\+\).*$/\1/')-1.noarch.rpm
if [[ $(uname -r | sed 's/^.*\(el[0-9]\+\).*$/\1/') == "el8" ]]
then    
  dnf -y module disable mysql
fi

yum install -y mysql-community-server-${mysql_version} mysql-shell-${mysql_version} mysql-router-community-${mysql_version}
rm -rf /var/lib/mysql/*
mysqld --initialize-insecure -u mysql --datadir /var/lib/mysql
systemctl start mysqld
mysql -u root -e "create user '${admin_username}'@'%' identified by '${admin_password}'; grant all privileges on *.* to '${admin_username}'@'%' with grant option;"

service firewalld stop
systemctl disable firewalld

echo "MySQL Server installed successfully!"
