#!/bin/bash
if [ -z $1 ]||[ -z $2 ]||[ -z $3 ]||[ -z $4 ]||[ -z $5 ]||[ -z $6 ]||[ -z $7 ]||[ -z $8 ]; then
cat << EOF
EXAMPLE:
    $0 $buildname $type $version $os $arch $filename $prefilename $notifytype
EOF
    exit 1
fi

buildname=$1
dtype=$2
version=$3
os=$4
arch=$5
filename=$6
prefilename=$7
notifytype=$8

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
cp -rfa $rootdir/etc/Deploy.xml ./
mkdir -p  $dtype && cd $dtype
cp -rfa $rootdir/src/$filename  ./
cp -rfa $rootdir/src/$prefilename  ./
cp -rfa $rootdir/src/$dtype  ./
cd ../
## ├── dest
## │   ├── rsb			──│
## │   │   ├── rsb4220.zip	  │
## │   │   └── install.sh		  │ rsb.zip
## │   ├── Deploy.xml		──│
## │   ├── PackageInfo.xml
## update Deploy.xml
echo "File is ready"
awk '{if(/DeployFileName/){sub(/>[^<]*</,">'"$dtype/$filename"'<")} {print > "Deploy.xml"}}' Deploy.xml
awk '{if(/PreDeployFileName/){sub(/>[^<]*</,">'"$dtype/$prefilename"'<")} {print > "Deploy.xml"}}' Deploy.xml
awk '{if(/DeployNotifyType/){sub(/>[^<]*</,">'"$notifytype"'<")} {print > "Deploy.xml"}}' Deploy.xml
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
# awk '{if(/OS/){sub(/>[^<]*</,">'"$os"'<")} {print > "PackageInfo.xml"}}' PackageInfo.xml
# awk '{if(/Arch/){sub(/>[^<]*</,">'"$arch"'<")} {print > "PackageInfo.xml"}}' PackageInfo.xml
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
