#!/bin/bash
#sudo systemctl start apache2.service
if [ "$DEPLOYMENT_GROUP_NAME" == "unicorn-dev-cron" ]
then
document_root=/var/www/devcron/magento2
pwd
cd $document_root
echo "current directory"
composer update
php bin/magento deploy:mode:set developer
php bin/magento setup:upgrade
php bin/magento setup:di:compile
php bin/magento setup:static-content:deploy -f

sudo chmod 700 $document_root/app/etc
sudo chown -R nginx:nginx $document_root
sudo find . -type f -exec chmod -c 644 {} \; && sudo find . -type d -exec chmod -c 755 {} \;

sudo chown -R nginx:nginx *
elif [ "$DEPLOYMENT_GROUP_NAME" == "Unicorn-stg-cron" ]
then
document_root=/var/www/stgcron/magento2
cd $document_root
composer update
php bin/magento deploy:mode:set developer
php bin/magento setup:upgrade
php bin/magento setup:di:compile
php bin/magento setup:static-content:deploy -f

sudo chmod 700 $document_root/app/etc
sudo chown -R nginx:nginx $document_root
else 
	exit 1

fi
