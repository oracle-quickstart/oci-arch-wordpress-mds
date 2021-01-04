#!/bin/bash
# Configure Instance, create cluster, add instances...

echo "Configuring MySQL Instance..."
while true
do
  systemctl status mysqld >/dev/null 2>&1
  if [[ $? -eq 0 ]]
  then
     echo "mysqld is running..."
     break
  fi
  echo "Waiting 10 seconds...."
  sleep 10
done
instance_ip=$(ip ad sh | grep ^2: -A 2 | grep inet | awk '{ print $2 }' | cut -d'/' -f1)
mysqlsh  -- dba configureInstance clusteradmin:${clusteradmin_password}@$instance_ip --interactive=false --restart=true

# SELinux
semanage port -a -t mysqld_port_t -p tcp 30000-50000

while true
do
  systemctl status mysqld >/dev/null 2>&1
  if [[ $? -eq 0 ]]
  then
     echo "mysqld is running..."
     break
  fi
  echo "Waiting 10 seconds...."
  sleep 10
done
hostname=$(hostname -s)
me=$${hostname: -1}
if [[ $me -eq 1 ]]
then
  echo "We are the primary node"
  mysqlsh  clusteradmin:${clusteradmin_password}@$instance_ip -- dba create-cluster "${cluster_name}" --localAddress=$instance_ip --autoRejoinTries=3
  echo "MySQL InnoDB Cluster created successfully!"
  primary_ip=$instance_ip
else
  echo "We are a secondary node"
  # finding ip of primary node
  primary_host="$${hostname%?}1"
  primary_ip=$(ping -c1 -q $primary_host | grep PING | awk -F '[()]' '{print $2}')
  #ip_nb=$${instance_ip##*.}
  #ip_nb=$(expr $ip_nb - $me + 1)
  #primary_ip="$${instance_ip%.*}.$ip_nb"
  
  # check is primary is available
  while true
  do
    mysqlsh clusteradmin:${clusteradmin_password}@$primary_ip --sql -e "select * from performance_schema.replication_group_members where member_host='$primary_ip'" | grep PRIMARY
    if [[ $? -eq 0 ]]
    then
       echo "Primary is running and reachable..."
       break
    fi
    echo "Waiting 10 seconds then trying again to connect to Primary instance...."
    sleep 10
  done
  # try to connect and clone - it may fail if the donor is already busy
  while true
  do
      mysqlsh clusteradmin:${clusteradmin_password}@$primary_ip -- cluster add-instance "clusteradmin:${clusteradmin_password}@$instance_ip:3306" --localAddress=$instance_ip --recoveryMethod=clone --autoRejoinTries=3 --waitRecovery=1
      if [[ $? -eq 0 ]]
      then
          echo "Node provisioning done successfully!"
          break
      fi
      echo "WARNING: not able to provision for the moment, will try again in 2 minutes!"
      sleep 120
  done
  sleep 10
  echo "MySQL InnoDB Cluster instance added successfully!"
fi   
# set the name
echo "Set the instance name to $hostname"
mysqlsh clusteradmin:${clusteradmin_password}@$primary_ip -- cluster set-instance-option "clusteradmin@$instance_ip:3306" 'label' "$hostname"

echo "All set for this instance !"
