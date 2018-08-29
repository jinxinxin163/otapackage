#!/bin/bash
result=`/tools/do_update.sh result`
if [ "$result" == "OK" ] ; then
	exit 0
else
	exit 1
fi

