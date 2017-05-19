#!/system/bin/sh
sworkdir=AIM8Q_GENERIC
dworkdir=/cust
sfilecmds=${sworkdir}/info/cmds
dfilecmds=${dworkdir}/info/cmds
dfileversion=${dworkdir}/info/version
dfilemd5=${dworkdir}/md5
unzip `ls *.zip`
if [ ! -d $sworkdir ]; then
        exit 1
fi
if [ ! -d $dworkdir ]; then
        exit 1
fi
# 1.modify cmds  
cp -rfa $sfilecmds $dfilecmds
# 2.modify version
major=`cat ${dfileversion}| cut -d "."  -f1`
minor=`cat ${dfileversion}| cut -d "."  -f2`
minor=`expr $minor + 1`
newversion=${major}.${minor}
sed -i "1c $newversion" ${dfileversion}
# 3.modify md5
oldcmdsmd5=`sed -n '/cmds/p' ${dfilemd5} | cut -d " " -f 1`
oldversionmd5=`sed -n '/version/p' ${dfilemd5} | cut -d " " -f 1`
newcmdsmd5=`md5sum $dfilecmds | cut -d " " -f1`
newversionmd5=`md5sum $dfileversion | cut -d " " -f1`
sed -i "s/$oldcmdsmd5/$newcmdsmd5/g" ${dfilemd5}
sed -i "s/$oldversionmd5/$newversionmd5/g" ${dfilemd5}
#rm -rf /data/*
#reboot
