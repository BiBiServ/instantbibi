#!/bin/bash
if [ -f .cache/glassfish-3.1.zip ]; then
	echo "GLASSFISH: Using cached zip"
	cp .cache/glassfish-3.1.zip .
else
	mkdir -p .cache
	echo "GLASSFISH: Downloading"
	wget http://download.java.net/glassfish/3.1/release/glassfish-3.1.zip
	echo "GLASSFISH: Caching"
	cp glassfish-3.1.zip .cache/
fi
