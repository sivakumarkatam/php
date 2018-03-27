#!/bin/bash
#sudo systemctl start apache2.service
echo $DEPLOYMENT_GROUP_NAME
echo "from start Server sh file"
if [ "$DEPLOYMENT_GROUP_NAME" == "unicorn-dev-cron" ]
then
	echo "start file execution is started"
	echo "enter to if condition for dev -cron"
	echo $DEPLOYMENT_GROUP_NAME
	document_root=/var/www/devcron/magento
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
	echo "start file execution is done"
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
   echo "executing else stratement in start service file"
	exit 1

fi
