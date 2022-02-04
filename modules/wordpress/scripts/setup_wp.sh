#!/bin/bash
#set -x


echo "Customize httpd.conf for WP..."
sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 512M/g' /etc/php.ini
sed -i '/<Directory "\/var\/www\/html">/,/<\/Directory>/ s/AllowOverride None/AllowOverride All/' /etc/httpd/conf/httpd.conf
sed -i '/<Directory "\/var\/www">/,/<\/Directory>/ s/AllowOverride None/AllowOverride All/' /etc/httpd/conf/httpd.conf
systemctl start httpd
systemctl enable httpd

echo "Starting wp-cli installation..."
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
sudo mv wp-cli.phar /usr/local/bin/wp
/usr/local/bin/wp --info
/usr/local/bin/wp core download --path='${wp_working_dir}/www/html/' --skip-content --force --version=${wp_version}
/usr/local/bin/wp config create --dbname=${wp_schema} --dbuser=${wp_name} --dbpass=${wp_password} --dbhost=${mds_ip} --skip-check --path='${wp_working_dir}/www/html/'
echo '${wp_site_admin_pass}' >> admin_password.txt
/usr/local/bin/wp core version --path='${wp_working_dir}/www/html'
/usr/local/bin/wp core install --path='${wp_working_dir}/www/html/'  --url=${wp_site_url} --title='${wp_site_title}' --admin_user=${wp_site_admin_user} --admin_email=${wp_site_admin_email} --prompt=admin_password < admin_password.txt
/usr/local/bin/wp core version --path='${wp_working_dir}/www/html'
chown -R apache:apache ${wp_working_dir}/www/html/
/usr/local/bin/wp plugin install ${wp_plugins} --path='${wp_working_dir}/www/html/'
chown -R apache:apache ${wp_working_dir}/www/html/
/usr/local/bin/wp theme install ${wp_themes} --path='${wp_working_dir}/www/html/'
setsebool -P httpd_can_network_connect 1
systemctl restart php-fpm
cp /home/opc/htaccess ${wp_working_dir}/www/html/.htaccess
rm /home/opc/htaccess
chown -R apache:apache ${wp_working_dir}/www/html/
find ${wp_working_dir}/www/html/ -type d -exec chmod 755 '{}' \;
find ${wp_working_dir}/www/html/ -type f -exec chmod 644 '{}' \;
chown -R apache:apache ${wp_working_dir}/www/html/
chcon -R --type httpd_sys_rw_content_t ${wp_working_dir}/www/html/
chmod 774 ${wp_working_dir}/www/html/.htaccess
/usr/local/bin/wp core update --version=${wp_version} --force --path='${wp_working_dir}/www/html'
/usr/local/bin/wp core version --path='${wp_working_dir}/www/html'
export wp_auto_update='${wp_auto_update}'
if [[ $wp_auto_update == "false" ]]; then
  echo "WordPress Auto Update will be disabled."
  echo "define( 'WP_AUTO_UPDATE_CORE', false );" >> /var/www/html/wp-config.php
else 
  echo "WordPress Auto Update will be enabled."
  echo "define( 'WP_AUTO_UPDATE_CORE', true );" >> /var/www/html/wp-config.php
fi
chown apache:apache /var/www/html/wp-config.php

echo "wp-cli installed, wp config, user, plugin theme executed."

export use_shared_storage='${use_shared_storage}'

if [[ $use_shared_storage == "true" ]]; then
  echo "Using shared storage, moving WP-CONTENT directory to shared NFS space."
  mkdir ${wp_shared_working_dir}/wp-content/
  
  echo "... moving WP-CONTENT/uploads ..."
  mkdir ${wp_shared_working_dir}/wp-content/uploads
  cp -r ${wp_working_dir}/www/html/wp-content/uploads/* ${wp_shared_working_dir}/wp-content/uploads
  rm -rf ${wp_working_dir}/www/html/wp-content/uploads/ 
  ln -s ${wp_shared_working_dir}/wp-content/uploads ${wp_working_dir}/www/html/wp-content/uploads
  chown -R apache:apache ${wp_shared_working_dir}/wp-content/uploads
  chown -R apache:apache ${wp_working_dir}/www/html/wp-content/uploads
  ls -latr ${wp_shared_working_dir}/wp-content/uploads
  echo "... WP-CONTENT/uploads moved to NFS..."

  echo "... moving WP-CONTENT/plugins ..."
  mkdir ${wp_shared_working_dir}/wp-content/plugins
  cp -r ${wp_working_dir}/www/html/wp-content/plugins/* ${wp_shared_working_dir}/wp-content/plugins
  rm -rf ${wp_working_dir}/www/html/wp-content/plugins/ 
  ln -s ${wp_shared_working_dir}/wp-content/plugins ${wp_working_dir}/www/html/wp-content/plugins
  chown -R apache:apache ${wp_shared_working_dir}/wp-content/plugins
  chown -R apache:apache ${wp_working_dir}/www/html/wp-content/plugins
  ls -latr ${wp_shared_working_dir}/wp-content/plugins
  echo "... WP-CONTENT/plugins moved to NFS..."

  echo "... moving WP-CONTENT/themes ..."
  mkdir ${wp_shared_working_dir}/wp-content/themes
  cp -r ${wp_working_dir}/www/html/wp-content/themes/* ${wp_shared_working_dir}/wp-content/themes
  rm -rf ${wp_working_dir}/www/html/wp-content/themes/ 
  ln -s ${wp_shared_working_dir}/wp-content/themes ${wp_working_dir}/www/html/wp-content/themes
  chown -R apache:apache ${wp_shared_working_dir}/wp-content/themes
  chown -R apache:apache ${wp_working_dir}/www/html/wp-content/themes
  ls -latr ${wp_shared_working_dir}/wp-content/themes
  echo "... WP-CONTENT/themes moved to NFS..."

  chown -R apache:apache ${wp_working_dir}/www/html/wp-content
  ls -latr ${wp_shared_working_dir}/wp-content/
  chown -R apache:apache /sharedwp
  echo "WP-CONTENT in shared NFS space."

  echo "Using shared storage, moving WP-ADMIN and WP-INCLUDES directories to shared NFS space."
  mkdir ${wp_shared_working_dir}/wp-admin/
  mkdir ${wp_shared_working_dir}/wp-includes/

  echo "... moving WP-ADMIN/* ..."
  cp -r ${wp_working_dir}/www/html/wp-admin/* ${wp_shared_working_dir}/wp-admin/
  rm -rf ${wp_working_dir}/www/html/wp-admin/
  ln -s ${wp_shared_working_dir}/wp-admin ${wp_working_dir}/www/html/wp-admin
  chown -R apache:apache ${wp_shared_working_dir}/wp-admin
  chown -R apache:apache ${wp_working_dir}/www/html/wp-admin
  ls -latr ${wp_shared_working_dir}/wp-admin
  echo "... WP-ADMIN/* moved to NFS..."

  echo "... moving WP-INCLUDES/* ..."
  cp -r ${wp_working_dir}/www/html/wp-includes/* ${wp_shared_working_dir}/wp-includes/
  rm -rf ${wp_working_dir}/www/html/wp-includes/
  ln -s ${wp_shared_working_dir}/wp-includes ${wp_working_dir}/www/html/wp-includes
  chown -R apache:apache ${wp_shared_working_dir}/wp-includes
  chown -R apache:apache ${wp_working_dir}/www/html/wp-includes
  ls -latr ${wp_shared_working_dir}/wp-includes
  echo "... WP-INCLUDES/* moved to NFS..."

  echo "... coping rest of the root level PHP files and .htaccess ..."
  cp -r ${wp_working_dir}/www/html/*.php ${wp_shared_working_dir}/
  cp -r ${wp_working_dir}/www/html/.htaccess ${wp_shared_working_dir}/
  chown -R apache:apache ${wp_shared_working_dir}/*.php
  chown -R apache:apache ${wp_working_dir}/www/html/*.php
  chown -R apache:apache ${wp_working_dir}/www/html/
  find ${wp_shared_working_dir}/ -type d -exec chmod 755 '{}' \;
  find ${wp_shared_working_dir}/ -type f -exec chmod 644 '{}' \;
  chown -R apache:apache ${wp_shared_working_dir}/
  chcon -R --type httpd_sys_rw_content_t ${wp_shared_working_dir}/
  chmod 774 ${wp_working_dir}/www/html/.htaccess
  ls -latr ${wp_shared_working_dir}/*.php
  ls -latr ${wp_shared_working_dir}/.htaccess  
  echo "... root level PHP files and .htaccess copied to NFS..."

  echo "... Changing /etc/httpd/conf/httpd.conf with Document set to new shared NFS space ..."
  sed -i 's/"\/var\/www\/html"/"\/sharedwp"/g' /etc/httpd/conf/httpd.conf
  echo "... /etc/httpd/conf/httpd.conf with Document set to new shared NFS space ..."
fi