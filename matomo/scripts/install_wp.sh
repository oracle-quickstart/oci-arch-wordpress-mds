#!/bin/bash
#set -x

echo "Starting Wordpress installation..."
cd /var/www/
wget https://wordpress.org/latest.tar.gz
tar zxvf latest.tar.gz
rm -rf html/ latest.tar.gz
mv wordpress html
chown apache. -R html
sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 512M/g' /etc/php.ini
systemctl start httpd
systemctl enable httpd

echo "Wordpress installed and Apache started !"

