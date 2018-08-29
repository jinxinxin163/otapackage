#!/bin/sh
update_package=/cache/update.zip
result_dest=/cache/recovery/command
locale_path=/cache/recovery/last_locale

if [ -e $update_package ]; then
    rm -f $update_package
fi

cp -rfa  ./update.zip /cache
mkdir /cache/recovery
echo "--update_package=/cache/update.zip" > ${result_dest}
echo -n "en_US" > ${locale_path}

# reboot to recovery mode for OTA
reboot recovery
