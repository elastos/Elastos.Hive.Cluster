#!/usr/local/bin/expect

set timeout 1000
set host [lindex $argv 0]
set username [lindex $argv 1]
set password [lindex $argv 2]
set src_file [lindex $argv 3]
set dest_file [lindex $argv 4]
set is_ctl_peer [lindex $argv 5]

set start_ipfs "/hive/ipfs daemon "
set start_ipfs-cluster "/hive/ipfs-cluster-service daemon "
set bootstrap "--bootstrap /ip4/10.10.80.101/tcp/9096/p2p/12D3KooWDibm5BGnyaNveXdvDo4LSws5d7XL3Fzk6HpzRazrbZvH"

puts "\n**** hive_deploy.sh for  $host ... ******************************************"
puts "**** scp  $src_file to $username@$host:$dest_file ******************************"

## deploy ####
spawn scp -r $src_file $username@$host:$dest_file
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

puts "**** scp $src_file to $username@$host:$dest_file finished. ***********************"

## login  ######
puts "**** start login ${username}@${host} ************************"
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

if { ${username} != "root" } {
	expect "*~"

	send "su \r"
	expect "*assword:" {send "$password\n"}
}

if { ${host} == "10.10.156.100" } {
    expect "*~]"
} else {
	expect "*#"
}
puts "**** login $username@$host success, start to exec command ***********************"

## run ipfs  ######
send "/hive/reset.sh \r"
if { ${host} == "10.10.156.100" } {
    expect "*~]"
} else {
	expect "*#"
}

send "nohup ${start_ipfs}&  \r"
send "\r"

if { ${host} == "10.10.156.100" } {
    expect "*~]"
} else {
	expect "*#"
}

if { ${is_ctl_peer} } {
	send "nohup ${start_ipfs-cluster}& \r"
	send "\r"
} else {
	send "nohup ${start_ipfs-cluster} ${bootstrap}& \r"
	send "\r"
}

if { ${host} == "10.10.156.100" } {
    expect "*~]"
} else {
	expect "*#"
}
send "exit \r"
send "exit \r"

expect eof