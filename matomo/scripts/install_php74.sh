#!/bin/bash
#set -x

#yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-$(cat /etc/redhat-release  | sed 's/^[^0-9]*\([0-9]\+\).*$/\1/').noarch.rpm
#yum -y install https://rpms.remirepo.net/enterprise/remi-release-$(cat /etc/redhat-release  | sed 's/^[^0-9]*\([0-9]\+\).*$/\1/').rpm

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

echo "MySQL Shell successfully installed !"

if [[ $(uname -r | sed 's/^.*\(el[0-9]\+\).*$/\1/') == "el8" ]]
then    
#  dnf -y module enable php:remi-7.4
  dnf -y install php 
  dnf -y install php-cli 
  dnf -y install php-mysqlnd 
  dnf -y install php-zip 
  dnf -y install php-gd 
  dnf -y install php-mbstring 
  dnf -y install php-xml 
  dnf -y install php-json 
  dnf -y install php-fpm
else
  yum-config-manager --enable remi-php74
  yum -y install php 
  yum -y install php-cli 
  yum -y install php-mysqlnd 
  yum -y install php-zip 
  yum -y install php-gd 
  yum -y install php-mcrypt
  yum -y install php-mbstring 
  yum -y install php-xml 
  yum -y install php-json
fi

echo "MySQL Shell & PHP successfully installed !"
