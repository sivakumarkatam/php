#!/bin/bash
#document_root=/var/www/dev/magento
deployment_root=/opt/deployment

if [ "$DEPLOYMENT_GROUP_NAME" == "unicorn-dev-cron" ]
then
          echo "service file execution is started"
	  echo $DEPLOYMENT_GROUP_NAME
	  document_root=/var/www/devcron/magento    
	  sudo cp -f -r $deployment_root/* /var/tmp/
	  sudo cd $document_root
	  #sudo php bin/magento maintenance:enable
          sudo rm -rf $document_root/*
          sudo mkdir -p $document_root
	  sudo cd $document_root
	  #sudo php bin/magento maintenance:enable
          sudo cp -f -r $deployment_root/* $document_root/
          sudo mkdir -p /run/php/
          sudo chown -R nginx:nginx /run/php/
	  echo "service file execution is done"
  elif [ "$DEPLOYMENT_GROUP_NAME" == "unicorn-stg-cron" ]
then
	document_root=/var/www/stgcron/magento	
	sudo cp -f -r $deployment_root/* /var/tmp/
	sudo rm -rf $document_root/*
	sudo mkdir -p $document_root
	sudo cp -f -r $deployment_root/* $document_root/
	sudo mkdir -p /run/php/
	sudo chown -R nginx:nginx /run/php/
	sudo systemctl start php-fpm
	sudo systemctl enable php-fpm
	sudo cp -f $deployment_root/scripts/StgEnv/env.php $document_root/app/etc/

else 
  echo "running else condition"
fi
