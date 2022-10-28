#!/bin/bash

#ask user for location they would like find log files in
#back files to the /var/backups/logBackerupper/logs
#append date/time to the log name
#do a MD5 hash of all the logs that are backuped dumped to /var/backups/logBackupper/hashed_logs.txt
#create an log of errors /var/backups/logBackupper/error/error.log

vardate=$(date +"%y-%m-%d_%H:%M:%S")
varbackupper=/var/backups/logBackupper
varerror=/var/backups/logBackupper/error
varlogs=/var/backups/logBackupper/logs

if [[ $(/usr/bin/id -u) -ne 0 ]]; then
        echo "This script is meant to be run as an Administrator! Please run again with Administrator Priveleges." 
        exit
fi

if [[ ! -d $varbackupper ]]
then
         mkdir $varbackupper
fi
if [[ ! -d $varlogs ]]
then
        mkdir $varlogs
fi
if [[ ! -d $varerror ]]
then
        mkdir $varerror
fi
if [ ! -f $varerror/error.log ]
then
        touch $varerror/error.log
fi
if [ ! -f $varbackupper/hash_log.txt ]
then
        touch $varbackupper/hash_log.txt
fi

exec 2>> $varerror/error.log

echo "What is the absolute path to the logs you would like backedup?"
read  backupdir

while [[ ! -d $backupdir ]]
do
        echo "Please enter a valid absolute path to the directory you are "
        read backupdir
done

if [[ -d $backupdir ]]
then
        echo "Finding and copying any .log files foudn in $backupdir"
        sleep 2
        for file in $(find $backupdir -type f -name '*.log*')
        do
                logname=$(echo $file | sed 's/.*\///')
                cp $file $varlogs/$vardate$logname
        done
        echo "Putting the hash values for all files coppied into $varbackupper/hash_log.txt"
        sleep 2
        echo " " >> $varbackupper/hash_log.txt
        echo " " >> $varbackupper/hash_log.txt
        echo "\\MD5 hashes for logs moved on $vardate\\" >> $varbackupper/hash_log.txt
        for file in $(find $backupdir -type f -name '*.log*')
        do
                md5sum $file >> $varbackupper/hash_log.txt
        done
fi
