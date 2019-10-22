#!/bin/bash

kill -9 $(ps -ef | grep ipfs | gawk '$0 !~/grep/ {print $2}' | tr -s '\n' ' ')