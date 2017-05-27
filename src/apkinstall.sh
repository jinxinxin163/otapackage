#!/system/bin/sh
statusfile=/cache/appstatus
workdir=`pwd`
tarfile=`ls *.tar.bz2`
appfile=$workdir/HelloActivity.apk
busybox tar xvf $tarfile
rm -rf $statusfile
#origmask=`umask`
#umask 076
chmod -R o+x /data/local/tmp
servertest appinstall $appfile 
sleep 1
x=1
while [ $x -le 30 ]
do
	if [ -f "$statusfile" ]; then
	    result=`cat /cache/appstatus`
	    if [ "$result" == "OK" ] ; then
        	exit 0
	    else
       	 	exit 1
	    fi
	else
	    x=$(( $x + 1 ))	
	    sleep 1	
	fi
done
#umask $origmask
exit 1
