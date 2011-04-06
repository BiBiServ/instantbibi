#!/bin/bash
DOWNLOAD=false
if [ -f .cache/glassfish-3.1.zip ]; then
	if [ `md5sum .cache/glassfish-3.1.zip | cut -d " " -f 1` = "a4951c1a7268f92fd0bd6fada89f29d6" ]; then
		echo "#GLASSFISH: Using cached zip"
		cp .cache/glassfish-3.1.zip .
	else
		echo "#GLASSFISH: Corrupt cached zip"
		DOWNLOAD=true
	fi
else
	DOWNLOAD=true
fi
if $DOWNLOAD; then
	mkdir -p .cache
	echo "#GLASSFISH: Downloading"
	wget http://download.java.net/glassfish/3.1/release/glassfish-3.1.zip
	echo "#GLASSFISH: Caching"
	cp glassfish-3.1.zip .cache/
fi
