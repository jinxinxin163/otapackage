#!/bin/bash
if [ $# !=  7 ] && [ $# != 8 ]; then
cat << EOF
EXAMPLE:
    $0 type version os arch imagefile installscript [preinstallscript] notifytype
EOF
    exit 1
fi

dtype=$1
version=$2
os=$3
arch=$4
imagefile=$5
installscript=$6
if [ $# -eq  8 ]; then
preinstallscript=$7
notifytype=$8
else
preinstallscript="null"
notifytype=$7
fi

mypwd=`pwd`
rootdir=$mypwd/../
bindir=$rootdir/bin
otadir=$rootdir/dest
srcdir=$rootdir/src

if [ ! -d $srcdir ]; then
	echo "Error : dir /src not exist"
	exit 1
fi

echo "Prepare directory"
if [ -d $otadir ]; then
	rm -rf $otadir
fi
mkdir -p $otadir && cd $otadir
echo "Prepare files"
cp -rfa $rootdir/etc/PackageInfo.xml ./
if [ "null" != "$preinstallscript" ] ; then
	cp -rfa $rootdir/etc/Deploy1.xml ./Deploy.xml
else
	cp -rfa $rootdir/etc/Deploy2.xml ./Deploy.xml
fi
mkdir -p  $dtype && cd $dtype
cp -rfa $rootdir/src/$installscript  ./
if [ "null" != "$preinstallscript" ] ; then
	cp -rfa $rootdir/src/$preinstallscript  ./
fi
cp -rfa $rootdir/src/$imagefile  ./
cd ../
## ├── dest
## │   ├── rsb			──│
## │   │   ├── rsb4220.zip	  │
## │   │   └── install.sh		  │ rsb.zip
## │   ├── Deploy.xml		──│
## │   ├── PackageInfo.xml
## update Deploy.xml
echo "File is ready"
if [ "null" != $preinstallscript ] ; then
	awk '{if(/DeployFileName/){sub(/>[^<]*</,">'"$dtype/$preinstallscript"'<")} {print > "Deploy.xml"}}' Deploy.xml
	awk '{if(/ResultCheckScript/){sub(/>[^<]*</,">'"$dtype/$installscript"'<")} {print > "Deploy.xml"}}' Deploy.xml
else
	awk '{if(/DeployFileName/){sub(/>[^<]*</,">'"$dtype/$installscript"'<")} {print > "Deploy.xml"}}' Deploy.xml	
fi
awk '{if(/RebootFlag/){sub(/>[^<]*</,">'"1"'<")} {print > "Deploy.xml"}}' Deploy.xml
# zip to zip1
passwd=`date +%s%N | md5sum | head -c 8`
zip -q -r -P $passwd $dtype.zip $dtype Deploy.xml
echo "Zip1 file $dtype.zip generated, password is : $passwd"  
#update PackageInfo.xml
#desd=`echo $passwd | openssl  enc -des-cbc  -nosalt -a -pass pass:#otasue*`
desd=`$bindir/enc $passwd`
echo "encrypted passwd is :$desd"
awk '{if(/PackageType/){sub(/>[^<]*</,">'"$dtype"'<")} {print > "PackageInfo.xml"}}' PackageInfo.xml
awk '{if(/Version/){sub(/>[^<]*</,">'"$version"'<")} {print > "PackageInfo.xml"}}' PackageInfo.xml
#awk '{if(/OS/){sub(/>[^<]*</,">'"$os"'<")} {print > "PackageInfo.xml"}}' PackageInfo.xml
#awk '{if(/Arch/){sub(/>[^<]*</,">'"$arch"'<")} {print > "PackageInfo.xml"}}' PackageInfo.xml
awk '{if(/Password/){sub(/>[^<]*</,">'"$desd"'<")} {print > "PackageInfo.xml"}}' PackageInfo.xml
# zip to zip2
zip -q -r ${dtype}-v${version}.zip  $dtype.zip PackageInfo.xml
echo "Zip2 file ${dtype}-v${version}.zip generated"
md5var=`md5sum "${dtype}-v${version}.zip" | cut -d ' ' -f 1`
mv ${dtype}-v${version}.zip ${dtype}-v${version}-${md5var}.zip
echo "Zip file ${dtype}-v${version}-${md5var}.zip generated"
# upload to ftp server
#$bindir/ftpput.sh $buildname ${dtype}-v${version}-${md5var}.zip
#echo "Put to ftp finished."
# remain last 
echo "OTAfilename:${dtype}-v${version}-${md5var}.zip";
