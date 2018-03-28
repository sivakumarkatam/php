#!/bin/bash
document_root=/var/www/magento2
web_root=/var/www/
document_root_cron_dev=/var/www/devcron/magento

if [ "$DEPLOYMENT_GROUP_NAME" == "unicorn-dev-cron" ]
then
echo "script is running on start app if condition in deployment group"
sudo semanage port -m -t http_port_t -p tcp 587
cd $document_root_cron_dev
pwd
composer update
php bin/magento deploy:mode:set developer
php bin/magento setup:upgrade
php bin/magento setup:di:compile
php bin/magento setup:static-content:deploy -f

sudo chmod 700 $document_root_cron_dev/app/etc
sudo chown -R nginx:nginx $document_root
sudo find . -type f -exec chmod -c 644 {} \; && sudo find . -type d -exec chmod -c 755 {} \;

sudo chown -R nginx:nginx *
cd $web_root
#sudo semanage fcontext -a -t httpd_sys_rw_content_t "$document_root_cron_dev(/.*)?"
#sudo semanage fcontext -a -t httpd_sys_rw_content_t "$document_root_cron_dev/app/etc(/.*)?"
#sudo semanage fcontext -a -t httpd_sys_rw_content_t "$document_root_cron_dev/var(/.*)?"
#sudo semanage fcontext -a -t httpd_sys_rw_content_t "$document_root_cron_dev/pub/media(/.*)?"
#sudo semanage fcontext -a -t httpd_sys_rw_content_t "$document_root_cron_dev/pub/static(/.*)?"
#sudo restorecon -Rv "$document_root_cron_dev/"
sudo chcon -R -t httpd_sys_rw_content_t "$document_root_cron_dev/generated"
sudo chcon -R -t httpd_sys_rw_content_t "$document_root_cron_dev/var"
sudo chcon -R -t httpd_sys_rw_content_t "$document_root_cron_dev/pub"
sudo setsebool httpd_can_network_connect_db on
#Allow HTTP to connect Redis
sudo semanage port -m -t http_port_t -p tcp 6379
sudo chown -R nginx:nginx $document_root_cron_dev

#
#Due to unknow cache issue we need to upgrade cache again as per Amith Pitre
#
cd $document_root_cron_dev
sudo rm -rf generated/code
sudo rm -rf generated/metadata
echo "script is completed on start app if condition in deployment group"

else

echo "script is running on start app else condition in deployment group not find"
sudo semanage port -m -t http_port_t -p tcp 587
cd $document_root
pwd
composer update
php bin/magento deploy:mode:set developer
php bin/magento setup:upgrade
php bin/magento setup:di:compile
php bin/magento setup:static-content:deploy -f

sudo chmod 700 $document_root/app/etc
sudo chown -R nginx:nginx $document_root
sudo find . -type f -exec chmod -c 644 {} \; && sudo find . -type d -exec chmod -c 755 {} \;

sudo chown -R nginx:nginx *
cd $web_root
#sudo semanage fcontext -a -t httpd_sys_rw_content_t "$document_root(/.*)?"
#sudo semanage fcontext -a -t httpd_sys_rw_content_t "$document_root/app/etc(/.*)?"
#sudo semanage fcontext -a -t httpd_sys_rw_content_t "$document_root/var(/.*)?"
#sudo semanage fcontext -a -t httpd_sys_rw_content_t "$document_root/pub/media(/.*)?"
#sudo semanage fcontext -a -t httpd_sys_rw_content_t "$document_root/pub/static(/.*)?"
#sudo restorecon -Rv "$document_root/"
sudo chcon -R -t httpd_sys_rw_content_t "$document_root/generated"
sudo chcon -R -t httpd_sys_rw_content_t "$document_root/var"
sudo chcon -R -t httpd_sys_rw_content_t "$document_root/pub"
sudo setsebool httpd_can_network_connect_db on
#Allow HTTP to connect Redis
sudo semanage port -m -t http_port_t -p tcp 6379
sudo chown -R nginx:nginx $document_root

#
#Due to unknow cache issue we need to upgrade cache again as per Amith Pitre
#
cd $document_root
sudo rm -rf generated/code
sudo rm -rf generated/metadata
#php "$document_root/bin/magento" setup:upgrade
sudo chmod 777 -R "$document_root/generated"
echo "script is completed on start app else condition in deployment group not find"

fi
