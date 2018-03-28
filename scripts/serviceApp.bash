#!/bin/bash
document_root_cron_dev=/var/www/devcron/magento
deployment_root=/opt/deployment

document_root=/var/www/magento2
#deployment_root=/opt/deployment
if [ "$DEPLOYMENT_GROUP_NAME" == "Unicorn-Magento-Admin-LT" ]
then
	sudo cp -f -r $deployment_root/* /var/tmp/
	sudo rm -rf $document_root/*
	sudo mkdir -p $document_root
	sudo cp -f -r $deployment_root/* $document_root/
	sudo mkdir -p /run/php/
	sudo chown -R nginx:nginx /run/php/
	sudo systemctl start php-fpm
	sudo systemctl enable php-fpm
	sudo cp -f $deployment_root/scripts/LoadEnv/env.php $document_root/app/etc/


elif [ "$DEPLOYMENT_GROUP_NAME" == "unicorn-dev-cron" ]
then
	echo "started service app file in if condition"
	sudo cp -f -r $deployment_root/* /var/tmp/
	sudo rm -rf $document_root_cron_dev/*
	sudo mkdir -p $document_root_cron_dev
	sudo cp -f -r $deployment_root/* $document_root_cron_dev/
	sudo mkdir -p /run/php/
	sudo chown -R nginx:nginx /run/php/
	sudo systemctl start php-fpm
	sudo systemctl enable php-fpm
	sudo cp -f $deployment_root/scripts/DevEnv/env.php $document_root_cron_dev/app/etc/
	echo "completed service app file in if condition"


else 
       echo "started service app file in else condition"
	sudo cp -f -r $deployment_root/* /var/tmp/
	sudo rm -rf $document_root_cron_dev/*
	sudo mkdir -p $document_root_cron_dev
	sudo cp -f -r $deployment_root/* $document_root_cron_dev/
	sudo mkdir -p /run/php/
	sudo chown -R nginx:nginx /run/php/
	sudo systemctl start php-fpm
	sudo systemctl enable php-fpm
	sudo cp -f $deployment_root/scripts/DevEnv/env.php $document_root_cron_dev/app/etc/
echo "completed service app file in else condition"
	exit 1

fi
