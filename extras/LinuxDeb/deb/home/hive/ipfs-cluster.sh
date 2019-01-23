#!/bin/bash

export `cat /home/hive/ipfs-cluster.conf`
/usr/local/bin/ipfs-cluster-service daemon &

