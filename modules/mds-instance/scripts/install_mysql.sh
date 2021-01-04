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
mysql -e "create user 'clusteradmin'@'%' identified by '${clusteradmin_password}'; grant all privileges on *.* to 'clusteradmin'@'%' with grant option; reset master;"
#set the report_host address
instance_ip=$(ip ad sh | grep ^2: -A 2 | grep inet | awk '{ print $2 }' | cut -d'/' -f1)
mysql -e "set persist_only report_host='$instance_ip'; restart"

firewall-cmd --zone=public --permanent --add-port=3306/tcp
firewall-cmd --zone=public --permanent --add-port=33060/tcp
firewall-cmd --zone=public --permanent --add-port=33061/tcp
firewall-cmd --reload

echo "MySQL Server installed successfully!"
