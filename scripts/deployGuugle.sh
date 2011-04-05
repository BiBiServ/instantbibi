#!/bin/bash
ls -l /tmp | grep guugle | nawk '{system("cd /tmp/"$8";touch resources/downloads/guugle-1.1.src.tar.gz;ant deploy")}'

