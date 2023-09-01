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
  local webhook_url="https://chat.googleapis.com/v1/spaces/AAAAyA6PNOM/messages?key=AIzaSyDdI0hCZtE6vySjMm-WEfRq3CPzqKqqsHI&token=RBz7WgmsIZk_-16l7TRqtdI-b-8VCn4WtizewOVb7Hg"
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
"/home/puneetkumar/mysql_replication_alert.sh" 66L, 2507B                                                                                                                                                 32,0-1        Top
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





                                                                                                                                                                                                          66,0-1        Bot
