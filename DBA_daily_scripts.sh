
#!/bin/bash

####################################################################################################
# USER Backup in MySQL .
####################################################################################################


set -x
BACKUP_DIR="/home/dba/usersync"
MYSQL_USER="root"
MYSQL_PASSWORD="root@123"
MYSQL=/usr/local/mysql/bin/mysql
echo -n "Enter Socket: "
read socket_name
echo -n "Enter Hostname: "
read host_name
cd $BACKUP_DIR
$MYSQL -u$MYSQL_USER -p$MYSQL_PASSWORD -S$socket_name -s -N -e"select concat('show grants for \'',user,'\'@\'',host,'\';') from mysql.user where user not in('mafiree','root','repl','replpuser','replusr','replusrnew','appuser');" > $BACKUP_DIR/import.sql 2> bkp.err
$MYSQL -u$MYSQL_USER -p$MYSQL_PASSWORD -S$socket_name -s -N -e"select distinct(host) from mysql.user where user not in ('','repluser','root','repl','replpuser','replusr','','appuser');" > $BACKUP_DIR/distincthost.txt
$MYSQL -u$MYSQL_USER -p$MYSQL_PASSWORD -S$socket_name -s -N < $BACKUP_DIR/import.sql > grant.log 1> grant.sql 2> grant.err
cat $BACKUP_DIR/distincthost.txt | while read LINE
do
sed -i "s/${LINE}/${host_name}/g" grant.sql
done
sed -i "s/$/;/g" grant.sql
exit 0



####################################################################################################
# Health_Chhek
####################################################################################################


!/bin/sh
set -x
date=`date '+%Y_%m_%d'`

/usr/local/mysql/bin/mysql -u user -p'pass' -h10.10.5.140 -P3306 -e"select now();" >> /home/dba/master_health_check/master_health_${date}.txt
/usr/local/mysql/bin/mysqladmin ping -u user -p'PASS' -hIP  --PPORT >> /home/dba/master_health_check/master_health_${date}.txt
exit 0





#!/bin/bash

####################################################################################################
# Checks MyISAM tables in MySQL . Sends user(s) a notification when found                          #
####################################################################################################


DBHost=`cat /home/puneetkumar/cred.txt  | grep 'DST_HOST' | cut -d '"' -f 2`
DBUser=`cat /home/puneetkumar/cred.txt | grep 'DST_USER' | cut -d '"' -f 2`
DBPwd=`cat /home/puneetkumar/cred.txt | grep 'DST_PASSWORD' | cut -d '"' -f 2`



# Function to send message to Google Chat
send_message_to_google_space() {
  local webhook_url="https://chat.googleapis.com/v1/spaces/AAAAmfYNxN8/"
  local message="$1"

  curl -X POST -H "Content-Type: application/json" -d "{\"text\": \"$message\"}" "$webhook_url"
}

alert_message="📢 MyISAM ENGINE  VERIFY  📢"


alert_message+="\n\n"
###################################################################################
TableCount=`/usr/local/mysql/bin/mysql -h$DBHost -u$DBUser -p$DBPwd  -e "select count(table_name) as cnt from information_schema.tables where ENGINE='MyISAM' and TABLE_TYPE='BASE TABLE' and table_schema not in ('information_schema','mysql','sys','performance_schema') ;"| tail -n 1`
/usr/local/mysql/bin/mysql -h$DBHost -u$DBUser -p$DBPwd  -e "select group_concat(concat(' ',table_Schema ,\".\",table_name,\"   \") )  from information_schema.tables where ENGINE='MyISAM' and TABLE_TYPE='BASE TABLE' and table_schema not in ('information_schema','mysql','sys','performance_schema') ;"> /tmp/check.out
list=`cat /tmp/check.out | tail -n 1`

if [ "$TableCount" = "0" ]; then

error="NO MyISAM tables found on  MySQL server : ($DBHost) "
status=1
fi

if [ "$TableCount" -gt "0" ]; then
    error="MyISAM Tables list on MySQL server : ($DBHost) is :: $list"
        status=1
fi


##########################################
# If found table list                   #
##########################################

if [ $status = 1 ]; then

      send_alert=1
alert_message+=" $error"
fi

if [[ $send_alert -eq 1 ]];
then
    send_message_to_google_space "$alert_message"
fi


0 10 * * * /bin/bash /root/mysql_table_engine_verify.sh 




-- DISK USAGE

project.txt
prod


                          cat disk_alert.sh
df -PkH | grep -vE '^Filesystem|tmpfs|cdrom' | awk '{ print $5 " " $6 }' | while read output;
do
  usep=$(echo $output | awk '{ print $1}' | cut -d'%' -f1 )
  partition=$(echo $output | awk '{print $2}' )
  if [ $usep -ge 95 ]; then

    msg="Running out of disk space $partition $(hostname) - amazon - IP ($usep%)"
    curl -X POST --data-urlencode "payload={\"channel\": \"#newrelic_disk_full\", \"username\": \"disk_script\", \"text\": \"Alert: $msg\", \"icon_emoji\": \":hankey:\"}" https://hooks.slack.com/
  fi
done



cat diskUsageAlert.sh
#!/bin/bash

# Function to send message to Google Chat
send_message_to_google_space() {
  local webhook_url="https://chat.googleapis.com/v1/spaces/AAAAMTVpo2A/"
  local message="$1"

  curl -X POST -H "Content-Type: application/json" -d "{\"text\": \"$message\"}" "$webhook_url"
}

threshold=85
send_alert=0

alert_message="\u23F0 Disk Usage Alert \u23F0"
alert_message+="\n\nHost IP : $(hostname -I | cut -d' ' -f1) (MySQL)"

# Get all the mounted disk paths
mounted_paths=($(df -h | grep -vE 'tmpfs|cdrom' | awk '{if (NR>1) print $6}'))

# Get the IP address of the current machine
ip_address=$(hostname -I | cut -d' ' -f1)

# Loop through the mounted disk paths and check disk usage
for path in "${mounted_paths[@]}"; do
  full_path=$(df -h "$path" | awk '{if (NR>1) print $0}' )
  usep=$(echo $full_path | awk '{if (NR>0) print $5}' | cut -d'%' -f1)
  if [[ $usep -gt $threshold ]];
  then
      send_alert=1
      alert_message+="\n$full_path \u26A0"
  fi
done

if [[ $send_alert -eq 1 ]];
then
    send_message_to_google_space "$alert_message"
fi 

0 */12 * * * /bin/bash /root/diskUsageAlert.sh


-- replication alerts


*/10  * * * * /bin/bash /home/puneetkumar/mysql_replication_alert.sh > /home/puneetkumar/logfile.log 2>&1

vim /home/puneetkumar/cred.txt
SRC_HOST="host"
SRC_USER="yser"
SRC_PASSWORD="pass"
DST_HOST="host"
DST_USER="user"
DST_PASSWORD="pass"


vim mysql_replication_alert.sh
#!/bin/bash

####################################################################################################
# Checks MySQL Replication status. Sends user(s) a notification when the replication goes down     #
####################################################################################################

status=0
SlaveHost=`cat /home/puneetkumar/cred.txt  | grep 'DST_HOST' | cut -d '"' -f 2`
SlaveUser=`cat /home/puneetkumar/cred.txt | grep 'DST_USER' | cut -d '"' -f 2`
SlavePwd=`cat /home/puneetkumar/cred.txt | grep 'DST_PASSWORD' | cut -d '"' -f 2`
threshold=300


# Function to send message to Google Chat
send_message_to_google_space() {
  local webhook_url="https://chat.googleapis.com/v1/spaces/AAAAyA6PNOM/messages?key"
  local message="$1"

  curl -X POST -H "Content-Type: application/json" -d "{\"text\": \"$message\"}" "$webhook_url"
}

alert_message="📢 🔴 MySQL replication  \u0042 \u0052 \u004F \u004B \u0045 \u004E 🔴 📢"
alert_message+="\n\nHost IP : $SlaveHost"

###################################################################################
#Grab the lines for each and use Gawk to get the last part of the string(Yes/No)  #
###################################################################################

SQLresponse=`mysql -h$SlaveHost -u$SlaveUser -p$SlavePwd mysql -e "show slave status \G" |grep -i "Slave_SQL_Running"|gawk '{print $2}'`
IOresponse=`mysql -h$SlaveHost -u$SlaveUser -p$SlavePwd mysql -e "show slave status \G" |grep -i "Slave_IO_Running"|gawk '{print $2}'`
Secondsbehind=`mysql -h$SlaveHost -u$SlaveUser -p$SlavePwd mysql -e "show slave status \G" |grep -i "Seconds_Behind_Master"|gawk '{print $2}'`

if [ "$SQLresponse" = "No" ]; then

error="Replication on the slave MySQL server($SlaveHost) has stopped working. Slave_SQL_Running: No"
status=1
fi

if [ "$IOresponse" = "No" ]; then
    error="Replication on the slave MySQL server($SlaveHost) has stopped working. Slave_IO_Running: No"
        status=1
fi

if [[ $Secondsbehind -gt $threshold ]]; then
error="Slave MySQL server($SlaveHost) has a Lag. of : $Secondsbehind Seconds "
status=1
fi
##########################################
# If the replication is not working      #
##########################################

if [ $status = 1 ]; then

      send_alert=1
alert_message+="\n\n $error"
fi

if [[ $send_alert -eq 1 ]];
then
    send_message_to_google_space "$alert_message"
fi


