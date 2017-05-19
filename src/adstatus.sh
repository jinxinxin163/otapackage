#!/system/bin/sh
result=`cat /cache/recovery/last_status`
if [ "$result" == "OK" ] ; then
        exit 0
else
        exit 1
fi
