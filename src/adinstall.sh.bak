#!/system/bin/sh

# OTA target
ota_fullpath="./update.zip"
update_package=/cache/update.zip

cp -rfa ${ota_fullpath} ${update_package}
/system/bin/servertest install ${update_package}
