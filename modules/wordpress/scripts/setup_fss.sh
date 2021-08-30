#!/bin/bash
#set -x

export use_shared_storage='${use_shared_storage}'

if [[ $use_shared_storage == "true" ]]; then
  echo "Mount NFS share for WP-CONTENT directory."
  yum install -y -q nfs-utils
  mkdir -p ${wp_shared_working_dir}
  echo '${mt_ip_address}:${wp_shared_working_dir} ${wp_shared_working_dir} nfs nosharecache,context="system_u:object_r:httpd_sys_rw_content_t:s0" 0 0' >> /etc/fstab
  setsebool -P httpd_use_nfs=1
  mount ${wp_shared_working_dir}
  mount
  echo "NFS share for WP-CONTENT directory mounted."
fi