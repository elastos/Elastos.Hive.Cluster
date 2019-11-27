#!/bin/bash


HIVE1=149.28.250.203
HIVE2=207.148.74.62
HIVE3=149.248.34.180
HIVE4=107.191.44.124

#HIVE5=52.83.159.189

eval SERVER1="$"HIVE$1""
eval SERVER2="$"HIVE$2""

server1=$1
server2=$2

TEST_SIZE=(4k 64k 512k 1M 2M 5M 10M) # Also as filename


# Uncomment it to use the fixed UID
# HIVE_UID=uid-e47d0e5c-853b-45a6-a5b0-286c5fd680fd
# HIVE_UID="uid-jw"

function show_error()
{
    logs "[Error] $1"
    echo "************************************************************"
    echo $1
    echo "************************************************************"
    rm 4k 64k 512k 1M 2M 5M 10M -f
    rm download_* -f
    rm stat_* -f
    continue
}

function show_steps()
{
    echo
    echo "************************************************************"
    echo $1
    echo "************************************************************"
}

function logs_time()
{
    start=$2
    end=$3
    start_s=$(echo $start | cut -d '.' -f 1)
    start_ns=$(echo $start | cut -d '.' -f 2)
    end_s=$(echo $end | cut -d '.' -f 1)
    end_ns=$(echo $end | cut -d '.' -f 2)
    time_ns=$(( ( 10#$end_s - 10#$start_s ) * 1000 + ( 10#$end_ns / 1000000 - 10#$start_ns / 1000000 ) ))
    echo "[$1] Begin:`date -d @$start_s +%H:%M:%S`, End:`date -d @$end_s +%H:%M:%S`. Last $time_ns ms" | tee -a $logfile $statisticsfile
}

function logs()
{
    echo [`date "+%Y-%m-%d %H:%M:%S"`] $1 >>$logfile
}

if [ $# -lt 1 ]; then
    echo "Please set the SERVER's number!"
    echo "Examples:"
    echo "  $0 1 2, this will test upload file to HIVE1, and download this file from HIVE2."
    exit 1
fi

logfile=SERVER$1_SERVER$2_`date "+%Y-%m-%d_%H:%M"`.log
statisticsfile=SERVER$1_SERVER$2_`date "+%Y-%m-%d_%H:%M"`.sta
touch $logfile
touch $statisticsfile
echo "===============================================================================================================" | tee -a $statisticsfile
echo "======================= Upload to:${SERVER1}, Download from:${SERVER2} =========================" | tee -a $logfile $statisticsfile
echo "===============================================================================================================" | tee -a $statisticsfile
echo " " | tee -a $statisticsfile
echo " " | tee -a $statisticsfile

for size in ${TEST_SIZE[@]}
do
    echo "=======================================================================================================" >>$logfile
    echo "################################# Now begin to test file size for ${size} ##############################" >>$logfile
    echo "=======================================================================================================" >>$logfile

        show_steps "Now Generate File ${size}"
        dd if=/dev/urandom of=${size} bs=${size} count=1 || show_error "The file ${size} cannot be created." 
        logs "[Info] The file ${size} has been created"

        show_steps "Now Generate UID"
        if [ "${HIVE_UID}" = "" ]; then
            HIVE_UID=`curl http://${SERVER1}:9095/api/v0/uid/new?uid=uid1127 | jq -r ".UID"` || show_error "UID cannot be created."
            echo "Your new UID is ${HIVE_UID}."
        else
            echo "You use FIXED UID ${HIVE_UID}."
        fi
        logs "[Info] Your UID is ${HIVE_UID}"

        show_steps "Now Upload File ${size} to Server ${SERVER1}"
        logs "[Info] Now Upload File ${size} to Server ${SERVER1}"
        time_start_upload=`date +%s.%N`
        curl -F file=@${size} "http://${SERVER1}:9095/api/v0/files/write?uid=${HIVE_UID}&path=/${size}&create=true" \
            || show_error "The file ${size} cannot be uploaded."
        time_end_upload=`date +%s.%N`
        logs "[Info] The file ${size} has been uploaded to Server ${SERVER1}"

        show_steps "Now Get File ${size} Stat from Server ${SERVER1}"
        HOME_HASH=`curl "http://${SERVER1}:9095/api/v0/files/stat?uid=${HIVE_UID}&path=/" | jq -r ".Hash"` \
            || show_error "The HASH of HOME directory cannot be got."
        echo  "The HASH of HOME directory is: ${HOME_HASH}."
        logs "[Info] The HASH of HOME directory is: ${HOME_HASH}."

        show_steps  "Now Login to Server ${SERVER2}"
        time_start_login_server2=`date +%s.%N`
        #curl "http://${SERVER2}:9095/api/v0/uid/login?uid=${HIVE_UID}&hash=/ipfs/${HOME_HASH}" || show_error "You cannot login ${SERVER2}."
        curl "http://${SERVER2}:9095/api/v0/uid/login?uid=${HIVE_UID}" || show_error "You cannot login ${SERVER2}."
        time_end_login_server2=`date +%s.%N`
        logs_time Login_${SERVER2} $time_start_login_server2 $time_end_login_server2
        logs "[Info] Login ${SERVER2} successfully"

       show_steps "Now sleep for 10 seconds"
       sleep 10

        for((t=0;t<120;t=$t+1))
        do
            show_steps  "Now Check File ${size} from Server ${SERVER2}"
            curl -m 10 "http://${SERVER2}:9095/api/v0/files/stat?uid=${HIVE_UID}&path=/${size}" >stat_${size}
            res=`jq -r .Hash stat_${size}`
            if [[ $res == Qm* ]];then
                time_end_GetFileHash_server2=`date +%s.%N`
                logs "[Info] You get the file ${size}'s Hash from ${SERVER2} successfully."
                flag="true"
                break
            else
                show_steps "Now sleep 5 seconds ."  
                sleep 5
            fi              
        done
        if [ -z ${flag} ];then
            logs "After more than10 minutes, you still cannot get file ${size}'s Hash from ${SERVER2}, please check your network."
            show_error "After more than 10 minutes, you still cannot get file ${size}'s Hash from ${SERVER2}, please check your network."
        fi

        show_steps  "Now Download File ${size} from Server ${SERVER2}"
        time_start_downloadfile_from_server2=`date +%s.%N`
        curl -m 299 "http://${SERVER2}:9095/api/v0/files/read?uid=${HIVE_UID}&path=/${size}" >download_${size} \
            || show_error "The file ${size} cannot be downloaded."
        time_end_downloadfile_from_server2=`date +%s.%N`
        logs "[Info] The file ${size} has beed downloaded successfully"

        show_steps  "Now verify the downloaded file ${size} is correct."
        diff ${size} download_${size}
        if [ $? -eq 0 ]; then
            logs "[Info] Congratulations! You upload the file ${size} to ${SERVER1} and get the correct copy from ${SERVER2} !"
            echo "Congratulations! You upload the file ${size} to ${SERVER1} and get the correct copy from ${SERVER2} !"
            echo "Succeeded for HIVE tests!(File: ${size})"
        else
            logs "[Warn] The downloaded file ${size} is different. Please check whether it is a tar file or something wrong."
            echo "The downloaded file ${size} is different. Please check whether it is a tar file or something wrong."
        fi
        echo "*******************************************************************************************************" | tee -a $logfile $statisticsfile
        echo "********************************** Time Statistics(File Size: ${size}) ************************************" | tee -a $logfile $statisticsfile
        echo "*******************************************************************************************************" | tee -a $logfile $statisticsfile
        logs_time Upload_File_To_${SERVER1} $time_start_upload $time_end_upload
        logs_time Get_HASH_From_${SERVER2} $time_end_upload $time_end_GetFileHash_server2
        logs_time Download_File_From_${SERVER2} $time_end_GetFileHash_server2 $time_end_downloadfile_from_server2


        echo "*******************************************************************************************************" | tee -a $logfile $statisticsfile
        echo "*******************************************************************************************************" | tee -a $logfile $statisticsfile
        echo " " | tee -a $logfile $statisticsfile
        echo " " | tee -a $logfile $statisticsfile
        rm 4k 64k 512k 1M 2M 5M 10M -f
        rm download_* -f
        rm stat_* -f
done
