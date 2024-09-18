#!/bin/bash

# run all init scripts for the container
# you can freely drop additional items here if they
# must be run before start
#
# if you replace this entrypoint.sh script, you should
# still perform this for loop to run all init scripts
for I in $(ls /entrypoint.d/*sh)
do
  . $I
done

# changing this will break dependent images
exec /usr/sbin/php-fpm -F
