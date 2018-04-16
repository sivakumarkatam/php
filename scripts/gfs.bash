#!/bin/bash


sudo wget http://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm &&  rpm -ivh epel-release-latest-7.noarch.rpm

sudo echo '[gluster38]
name=Gluster 3.8
baseurl=http://mirror.centos.org/centos/7/storage/$basearch/gluster-3.8/
gpgcheck=0
enabled=1' >  /etc/yum.repos.d/Gluster.repo
sudo yum install -y centos-release-gluster
sudo yum install -y glusterfs-client
sudo yum install -y wget curl vim zip

sleep 10
az=`curl http://169.254.169.254/latest/meta-data/placement/availability-zone/`

#echo "AZ is: $az"
sleep 5

if [ "$az" == "ap-southeast-1a" ]
 then
sudo mount -t glusterfs -o context=system_u:object_r:httpd_sys_rw_content_t:s0  gfs1.unicorn.cloud:/gv0 /var/www/magento2/pub/media/

#sudo mount -t glusterfs gfs1.unicorn.cloud:/gv0 /var/www/magento2/pub/media/

echo "AZ is: $az"
#echo 'gfs1.unicorn.cloud:/gv0 /var/www/magento2/pub/media glusterfs defaults,_netdev backupvolfile-server=gfs2.unicron.cloud   0 0' >> /etc/fstab
ABC=`sudo mount -t glusterfs -o context=system_u:object_r:httpd_sys_rw_content_t:s0  gfs1.unicorn.cloud:/gv0 /var/www/magento2/pub/media/`
echo "$ABC"
elif [ "$az" == "ap-southeast-1b" ]
 then
#ABC=`sudo mount -t glusterfs -o context=system_u:object_r:httpd_sys_rw_content_t:s0  gfs2.unicorn.cloud:/gv0 /var/www/magento2/pub/media/`
#sudo mount -t glusterfs gfs1.unicorn.cloud:/gv0 /var/www/magento2/pub/media/
echo "ABC"
echo "AZ is: $az"

elif [ "$az" == "ap-southeast-1c" ]
 then
#sudo mount -t glusterfs -o context=system_u:object_r:httpd_sys_rw_content_t:s0  gfs3.unicorn.cloud:/gv0 /var/www/magento2/pub/media/
#sudo mount -t glusterfs gfs1.unicorn.cloud:/gv0 /var/www/magento2/pub/media/
echo "AZ is: $az"
else

exit 1

fi
sudo chcon -R -t httpd_sys_rw_content_t /var/www/magento2/
sudo df -h


