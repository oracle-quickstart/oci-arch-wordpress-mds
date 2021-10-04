#!/bin/bash
#set -x

echo "Starting wp-cli installation..."
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
sudo mv wp-cli.phar /usr/local/bin/wp
/usr/local/bin/wp --info
/usr/local/bin/wp core download --path='${wp_working_dir}/www/html/'
/usr/local/bin/wp config create --dbname=${wp_schema} --dbuser=${wp_name} --dbpass=${wp_password} --dbhost=${mds_ip} --skip-check --path='${wp_working_dir}/www/html/'
echo '${wp_site_admin_pass}' >> admin_password.txt
/usr/local/bin/wp core install --path='${wp_working_dir}/www/html/'  --url=${wp_site_url} --title='${wp_site_title}' --admin_user=${wp_site_admin_user} --admin_email=${wp_site_admin_email} --prompt=admin_password < admin_password.txt
chown -R apache:apache ${wp_working_dir}/www/html/
/usr/local/bin/wp plugin install ${wp_plugins} --path='${wp_working_dir}/www/html/'
chown -R apache:apache ${wp_working_dir}/www/html/
/usr/local/bin/wp theme install ${wp_themes} --path='${wp_working_dir}/www/html/'
setsebool -P httpd_can_network_connect 1
systemctl restart php-fpm
cp /home/opc/htaccess ${wp_working_dir}/www/html/.htaccess
rm /home/opc/htaccess
chmod 774 ${wp_working_dir}/www/html/.htaccess
chown -R apache:apache ${wp_working_dir}/www/html/
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
fi