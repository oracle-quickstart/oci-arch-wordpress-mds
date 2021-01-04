#!/bin/bash
#set -x

cd /var/www/
wget https://wordpress.org/latest.tar.gz
tar zxvf latest.tar.gz
rm -rf html/ latest.tar.gz
mv wordpress html
chown apache. -R html

systemctl start httpd
systemctl enable httpd


echo "Wordpress installed and Apache started !"
