
##################################################################################
#     DB status check If not running auto start and send mail notification       #
##################################################################################

#!/bin/ksh
. ~/.profile            ===> This is optional based on your environment variables
ps -ef|grep mysql|grep mysql.sock|grep -v grep

if [ $? -eq 0 ]
then
  echo "MYSQL Process Check OK"
else
echo "MYSQL is Not Running .... Starting" | mailx -s "MySQL on `hostname` is not running..... STARTING NOW .... " test123@gmail.com
  startmysql
 fi
