#!/bin/bash
echo "stop server is running"
isExistApp=`pgrep apache2`
if [[ -n  $isExistApp ]]; then
   sudo service apache2 stop        
fi
echo "stop server is done"
