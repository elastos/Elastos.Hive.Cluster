#!/bin/bash

export `cat /home/hive/ipfs.conf`
/usr/local/bin/ipfs daemon &
 
