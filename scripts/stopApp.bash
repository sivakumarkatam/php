#!/bin/bash
echo "stop server is running"
isExistApp=`pgrep apache2`
if [[ -n  $isExistApp ]]; then
   sudo service apache2 stop        
fi
echo "stop server is done"
echo $DEPLOYMENT_GROUP_NAME
if [ "$DEPLOYMENT_GROUP_NAME" == "unicorn-dev-cron" ]
then
echo "started stop app file in if condition"
fi
