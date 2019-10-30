#!/usr/bin/expect
set timeout 1000
            
set RUN_PATH "/hive"
set ctl-peer "10.10.80.101"
set peer1 "10.10.80.10"
set peer2 "10.10.156.100"
set peer3 "10.10.156.160"

set hive1 "149.28.250.203"
set hive2 "207.148.74.62"
set hive3 "149.248.34.180"

puts "\ndeploy start ... "

# # # # # # # # copy to hive1 # # # # # # # #
spawn scp /home/jiawang/share/ipfs/bin/ipfs hive1:/hive
expect "100%"
expect eof

set ipfs-cluseter-service "/home/jiawang/share/ipfs/src/Elastos.NET.Hive.Cluster/cmd/ipfs-cluster-service/ipfs-cluster-service"
spawn scp ${ipfs-cluseter-service} hive1:/hive/;
expect "100%"
expect eof

spawn scp /home/jiawang/share/ipfs/bin/reset.sh hive1:/hive
expect "100%"
expect eof

spawn scp /home/jiawang/share/ipfs/bin/hivetest.sh hive1:/hive
expect "100%"
expect eof

spawn scp /mnt/hgfs/share/ipfs/key/swarm.key hive1:/hive
expect "100%"
expect eof

set hive_deploy "/home/jiawang/share/ipfs/bin/hive_deploy.sh"
spawn scp ${hive_deploy} hive1:/hive;
expect "*#"

# # # # # # # # loging to hive1 # # # # # # # #
spawn ssh hive1
expect "*#"
puts "\nlogin hive1 success. "

# # # # # # # # elastos deploy and test # # # # # # # #
puts "\n\n1. deploy  ${hive1}"
send "/hive/hive_deploy.sh ${hive1} hive elastos@HIVE /hive  true \r"

expect "*#"
puts "\n\n2. deploy  ${hive2}"
send "/hive/hive_deploy.sh ${hive2} hive elastos@HIVE /hive false \r"

expect "*#"
puts "\n\n3. deploy  ${hive3}"
send "/hive/hive_deploy.sh ${hive3} hive elastos@HIVE /hive false \r"


# # # # # # # # lb deploy and test # # # # # # # #
#/hive/hive_deploy.sh 10.10.80.10 root storage@root /hive/ipfs-cluster-service /hive/ipfs-cluster-service
## serv1
#puts "\n#### deploy  ${ctl-peer}********************************************************"
#send "/hive/hive_deploy.sh ${ctl-peer} zhh storage@root /hive/ / true \r"

#expect "*#"
#puts "\n#### deploy  ${peer1}********************************************************"
#send "/hive/hive_deploy.sh ${peer1} root storage@root /hive/ / false \r"

#expect "*#"
#puts "\n#### deploy  ${peer2}********************************************************"
#send "/hive/hive_deploy.sh ${peer2} root storage@root /hive/ / false \r"

#expect "*~]"
#puts "\n#### deploy  ${peer3}********************************************************"
#send "/hive/hive_deploy.sh ${peer3} root storage@root /hive/ / false \r"

#expect "*~"
#send "exit \r"

interact
