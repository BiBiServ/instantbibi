#!/bin/bash
DOWNLOAD=false
if [ -f .cache/glassfish-3.1.1.zip ]; then
	if [ `md5sum .cache/glassfish-3.1.1.zip | cut -d " " -f 1` = "bf92c2c99b3d53b83bbc8c7e2124a897" ]; then
		echo "#GLASSFISH: Using cached zip"
		cp .cache/glassfish-3.1.1.zip .
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
	wget http://download.java.net/glassfish/3.1.1/release/glassfish-3.1.1.zip
	echo "#GLASSFISH: Caching"
	cp glassfish-3.1.1.zip .cache/
fi
