#!/bin/bash

OS=`uname`

if [ $OS = SunOS ] ; then
    PS="ps -ef ";
else 
    PS="ps aux ";
fi;


for i in `$PS | grep $USER | grep bibigf31 | grep -v grep | awk '{print $2}'`
	do
		kill -9 $i
		echo "killed $i"
	done
