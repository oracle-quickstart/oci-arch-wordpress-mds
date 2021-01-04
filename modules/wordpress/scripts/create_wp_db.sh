#!/bin/bash 

#mysqlsh ${admin_username}:'${admin_password}'@${mds_ip} --sql -e "CREATE DATABASE ${wp_schema};"
#mysqlsh ${admin_username}:'${admin_password}'@${mds_ip} --sql -e "CREATE USER ${wp_name} identified by '${wp_password}';"
#mysqlsh ${admin_username}:'${admin_password}'@${mds_ip} --sql -e "GRANT ALL PRIVILEGES ON ${wp_schema}.* TO ${wp_name};"

mysqlsh --user ${admin_username} --password=${admin_password} --host ${mds_ip} --sql -e "CREATE DATABASE ${wp_schema};"
mysqlsh --user ${admin_username} --password=${admin_password} --host ${mds_ip} --sql -e "CREATE USER ${wp_name} identified by '${wp_password}';"
mysqlsh --user ${admin_username} --password=${admin_password} --host ${mds_ip} --sql -e "GRANT ALL PRIVILEGES ON ${wp_schema}.* TO ${wp_name};"

echo "WordPress Database and User created !"
