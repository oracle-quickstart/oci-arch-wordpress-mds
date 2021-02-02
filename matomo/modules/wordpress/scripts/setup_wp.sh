#!/bin/bash
#set -x

echo "Starting wp-cli installation..."
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
sudo mv wp-cli.phar /usr/local/bin/wp
/usr/local/bin/wp --info
/usr/local/bin/wp core download
/usr/local/bin/wp config create --dbname=${wp_schema} --dbuser=${wp_name} --dbpass=${wp_password} --dbhost=${mds_ip} --skip-check --path='/var/www/html/'
echo '${wp_site_admin_pass}' >> admin_password.txt
/usr/local/bin/wp core install --path='/var/www/html/'  --url=${wp_site_url} --title='${wp_site_title}' --admin_user=${wp_site_admin_user} --admin_email=${wp_site_admin_email} --prompt=admin_password < admin_password.txt
chown -R apache:apache /var/www/html/
/usr/local/bin/wp plugin install ${wp_plugins} --path='/var/www/html/'
chown -R apache:apache /var/www/html/
/usr/local/bin/wp theme install ${wp_themes} --path='/var/www/html/'
chown -R apache:apache /var/www/html/
echo "wp-cli installed, wp config, user, plugin theme executed."
