#!/system/bin/sh

# OTA target
ota_fullpath="./update.zip"
update_package=/cache/update.zip

result_dest=/cache/recovery/command
locale_path=/cache/recovery/last_locale

cp -rfa ${ota_fullpath} ${update_package}
mkdir /cache/recovery
echo "--update_package=/cache/update.zip" > ${result_dest}

# temportary solution
echo -n "en_US" > ${locale_path}

# remove the update package
rm -f $ota_fullpath

# reboot to recovery mode for OTA
reboot recovery

