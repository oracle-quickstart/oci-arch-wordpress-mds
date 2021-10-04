#!/bin/bash
#set -x

echo "Starting Wordpress installation..."
cd ${wp_working_dir}/www/
wget https://wordpress.org/latest.tar.gz
tar zxvf latest.tar.gz
rm -rf html/ latest.tar.gz
mv wordpress html
chown apache. -R html
sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 512M/g' /etc/php.ini
sed -i '/<Directory "\/var\/www\/html">/,/<\/Directory>/ s/AllowOverride None/AllowOverride All/' /etc/httpd/conf/httpd.conf
sed -i '/<Directory "\/var\/www">/,/<\/Directory>/ s/AllowOverride None/AllowOverride All/' /etc/httpd/conf/httpd.conf
systemctl start httpd
systemctl enable httpd

echo "Wordpress installed and Apache started !"

