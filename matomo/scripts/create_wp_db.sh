#!/bin/bash 

mysqlsh --user ${admin_username} --password=${admin_password} --host ${mds_ip} --sql -e "CREATE DATABASE ${wp_schema};"
#mysqlsh --user ${admin_username} --password=${admin_password} --host ${mds_ip} --sql -e "CREATE USER ${wp_name} identified by '${wp_password}';"
mysqlsh --user ${admin_username} --password=${admin_password} --host ${mds_ip} --sql -e "CREATE USER ${wp_name} IDENTIFIED WITH mysql_native_password BY '${wp_password}';"
mysqlsh --user ${admin_username} --password=${admin_password} --host ${mds_ip} --sql -e "GRANT ALL PRIVILEGES ON ${wp_schema}.* TO ${wp_name};"

echo "WordPress Database and User created !"
