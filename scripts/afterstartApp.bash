#!/bin/bash
document_root=/var/www/magento2
document_root_cron_dev=/var/www/devcron/magento
web_root=/var/www/
if [ "$DEPLOYMENT_GROUP_NAME" == "unicorn-dev-cron" ]
then


echo "running afterstart in  if deployment group condition"
cd $document_root_cron_dev

sudo php bin/magento cron:install -f
#sudo php bin/magento maintenance:disable
#or
#crontab -l | { cat; echo "* * * * * /usr/bin/php /var/www/magento2/bin/magento cron:run 2>&1 | grep -v "Ran jobs by schedule" >> /var/www/magento2/var/log/magento.cron.log"; } | crontab -

#crontab -l | { cat; echo "* * * * * /usr/bin/php /var/www/magento2/update/cron.php >> /var/www/magento2/var/log/update.cron.log"; } | crontab -

#crontab -l | { cat; echo "* * * * * /usr/bin/php /var/www/magento2/bin/magento setup:cron:run >> /var/www/magento2/var/log/setup.cron.log"; } | crontab -
echo "completed afterstart in  if deployment group condition"

else
echo "running afterstart in else condition"
document_root=/var/www/magento2
cd $document_root
#sudo php bin/magento maintenance:disable

echo "running afterstart in else condition"
exit 1

fi
