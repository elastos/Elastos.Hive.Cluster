#!/usr/bin/expect
set timeout 1000
            
set RUN_PATH "/hive"
set ctl-peer "10.10.80.101"
set peer1 "10.10.80.10"
set peer2 "10.10.156.100"
set peer3 "10.10.156.160"

puts "\n************  start deploy in deploy.sh ... ****************************************"

# cp to hive1
#set ipfs-cluseter-service "/home/jiawang/share/ipfs/src/ipfs-cluster-0.11.1/cmd/ipfs-cluster-service/ipfs-cluster-service"
#spawn scp ${ipfs-cluseter-service} hive1:/hive/;
#expect "100%"
#expect eof

#spawn scp /home/jiawang/share/ipfs/bin/ipfs hive1:/hive
#expect "100%"
#expect eof

spawn scp /home/jiawang/share/ipfs/bin/reset.sh hive1:/hive
expect "100%"
expect eof

set hive_deploy "/home/jiawang/share/ipfs/bin/hive_deploy.sh"
spawn scp ${hive_deploy} hive1:/hive;
expect "*#"

# loging to hive1
spawn ssh hive1
expect "*#"
puts "\n*********LOGIN hive1 SUCCESS  START TO EXCE COMMAND*********************************"

#/hive/hive_deploy.sh 10.10.80.10 root storage@root /hive/ipfs-cluster-service /hive/ipfs-cluster-service
## serv1
puts "\n#### deploy  ${ctl-peer}********************************************************"
send "/hive/hive_deploy.sh ${ctl-peer} zhh storage@root /hive/ / true \r"

expect "*#"
puts "\n#### deploy  ${peer1}********************************************************"
send "/hive/hive_deploy.sh ${peer1} root storage@root /hive/ / false \r"

expect "*#"
puts "\n#### deploy  ${peer2}********************************************************"
send "/hive/hive_deploy.sh ${peer2} root storage@root /hive/ / false \r"

expect "*~]"
puts "\n#### deploy  ${peer3}********************************************************"
send "/hive/hive_deploy.sh ${peer3} root storage@root /hive/ / false \r"

expect "*~"
send "exit \r"
interact
