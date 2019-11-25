#!/usr/local/bin/expect

set timeout 1000

set host [lindex $argv 0]
set username [lindex $argv 1]
set password [lindex $argv 2]
set src_file [lindex $argv 3]
set is_ctl_peer [lindex $argv 4]

set hivework "/home/$username/hive"
set start_ipfs "${hivework}/ipfs daemon "
set start_ipfs-cluster "${hivework}/ipfs-cluster-service daemon "
set bootstrap "--bootstrap /ip4/149.28.250.203/tcp/9096/p2p/12D3KooWAcu6DJVJLFs1mQQLpP2FS81pvoqXsdAC1xJ19y8Q9YF2"


puts "->${host} start ... "
puts "-->scp $src_file to $username@$host:/home/$username  "

## deploy ####
spawn scp -r "${src_file}" "$username@$host:/home/$username"
expect {
  "(yew/no)?"
  {
    send "yes\n"
    expect "*assword:" {send "$password\n"}
  }
  "*assword:"
  {
    send "$password\n"
  }
}

if { ${host} == "10.10.156.100" } {
    expect "*~]"
} else {
	expect "*#"
}

## login  ######
puts "-->login ${username}@${host} "
spawn ssh ${username}@${host}

expect {
  "(yew/no)?"
  {
    send "yes\n"
    expect "*assword:" {send "$password\n"}
  }
  "*assword:"
  {
    send "$password\n"
  }
}

expect "*~"

puts "login $username@$host success"

## run ipfs  ######
puts "-->run ipfs "
send "export PATH=\"\$PATH:${hivework}/\" \r"

send "${hivework}/reset.sh \r"
expect "*~"

send "rm -rf ${hivework}/ipfs_output.log \r"
expect "*~"

send "nohup ${start_ipfs} >${hivework}/ipfs_output.log 2>&1 &  \r"
send "\r"
expect "*~"

puts "-->run ipfs-cluster "
send "rm -rf ${hivework}/ipfs-cluster_output.log \r"
expect "*~"

if { ${is_ctl_peer} } {
	send "nohup ${start_ipfs-cluster} >${hivework}/ipfs-cluster_output.log 2>&1 & \r"
	send "\r"
	send "cat  ${hivework}/ipfs-cluster_output.log | grep /ip4/${host}/tcp/9096/ | tail -1 \r"
	set bootstrap $expect_out(0,string)
	puts "\n$bootstrap:{bootstrap}"
} else {
	send "nohup ${start_ipfs-cluster} ${bootstrap} >${hivework}/ipfs-cluster_output.log 2>&1 & \r"
	send "\r"
}

expect "*~"
send "exit \r"

puts "-->$host finished \n\n"

expect eof