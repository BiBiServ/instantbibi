#!/bin/bash
for i in `ps aux | grep "bibigf31" | awk '{print $2}'`
	do
		kill -9 $i
		echo "[sudo] killed $i"
	done
