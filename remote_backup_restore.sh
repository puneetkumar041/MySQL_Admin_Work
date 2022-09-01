#!/bin/bash
SSH_ARGS='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'
DATE=$(date +%d-%m-%Y)
#MAILS="gautam.kumar2@justdial.com,aaditya.dubey@justdial.com,karnish.master@justdial.com"
MAILS="puneet.optum@gmail.com"
SERVERS=(172.29.13.122)
COUNTFILE="/home/web_backup/sp_completion_count_dont_delete.txt"


function ERROR() {
if [ $? -ne 0 ]; then
        echo "dump process has failed on 6.180" | mail -s "FAILED: dump process has failed on $DATE" $MAILS
        /scripts/standard_sms_sending_script.sh -m "dump process has failed on 10.42" -f /scripts/groupon_sms_list.txt
        exit 1
fi
}

function SUCCESS(){
if [ "$?" -eq "0" ]; then
	echo "dump process completed successfully on 6.180"  | mail -s "SUCCESS: dump process completed Successfully on $DATE" $MAILS
        /scripts/standard_sms_sending_script.sh -m "dump process completed successfully on 10.42" -f /scripts/groupon_sms_list.txt
fi
}

#########################
echo "Truncating count file"
truncate -s0 /home/web_backup/sp_completion_count_dont_delete.txt
######################### 


for i in ${SERVERS[@]};do
   echo -e "\nremoving companymaster_extract_temp.txt on ${i}"
   ssh  ${SSH_ARGS}  -q  web_backup@${i} "rm -fv /tmp/companymaster_extract_temp.txt"
   ERROR
done


echo -e  "\nStep 2.1 : Running outfile_infile_report on all 122"

for i in ${SERVERS[@]};do
   echo  "Copying the SP script to ${i}"
   scp  ${SSH_ARGS}  -q  /scripts/outfile_infile_report.sh web_backup@${i}:/home/web_backup/
   ERROR
done

ssh -ttt ${SSH_ARGS}  -q  web_backup@172.29.13.122 "sudo sh /home/web_backup/outfile_infile_report.sh > /tmp/outfile_infile_report.log 2>&1 " &

echo -e "\nRunning simultaneously on all 122"

COUNT2=0
while true
do
COUNT1=`wc -l ${COUNTFILE} | awk '{print $1}'`
if [ $COUNT1 -eq 9 ]
then
###################
echo -e "outfile_infile_report completed on all 122 successfully proceeding further...  `date +%H:%M:%S` \n"
###################
break
fi
sleep 300
let COUNT2=$COUNT2+1
if [ $COUNT2 -eq 36 ]
then
###################
echo "outfile_infile_report timed out... check /tmp/outfile_infile_report.log on all 122  `date +%H:%M:%S`"
###################
exit 1
fi
echo  "waiting for completion...  `date +%H:%M:%S`"
done

############################################

echo -e "\nStep 3.0 : Transferring tbl_sf_weekly_report & cat_data_count_outfile_infile_report to 17.122"

echo "Dumping tables  tbl_sf_weekly_report & cat_data_count_outfile_infile_report  from 10.42 & Compressing it"
ssh  ${SSH_ARGS}  -q  web_backup@172.29.13.122 "sudo mysqldump   dbteam_temp tbl_sf_weekly_report_mumbai   > /tmp/tbl_sf_weekly_report_mumbai.sql  && gzip -fv /tmp/tbl_sf_weekly_report_mumbai.sql && sudo mysqldump   dbteam_temp cat_data_count_outfile_infile_report_mumbai   > /tmp/cat_data_count_outfile_infile_report_mumbai.sql  && gzip -fv /tmp/cat_data_count_outfile_infile_report_mumbai.sql"
ERROR

echo -e "\nTransferring tables from all 122 to 17.122" 

scp  ${SSH_ARGS}  -q  web_backup@172.29.13.122:/tmp/cat_data_count_outfile_infile_report_mumbai.sql.gz    /home/web_backup/ 
ERROR

scp  ${SSH_ARGS}  -q  web_backup@172.29.13.122:/tmp/tbl_sf_weekly_report_mumbai.sql.gz    /home/web_backup/ 
ERROR

echo -e "\nDecompressing && Restoring cat_data_count_outfile_infile_report to dbteam_temp on 6.180 from all 122"
gunzip -fv /home/web_backup/cat_data_count_outfile_infile_report_mumbai.sql.gz  && sudo mysql  --socket=/var/lib/SQL/mysql/mysql.sock  dbteam_temp  < /home/web_backup/cat_data_count_outfile_infile_report_mumbai.sql && rm -fv /home/web_backup/cat_data_count_outfile_infile_report_mumbai.sql
ERROR

echo -e "\nDecompressing && Restoring tbl_sf_weekly_report to dbteam_temp on 17.122 from all 122"
gunzip -fv /home/web_backup/tbl_sf_weekly_report_mumbai.sql.gz  && sudo mysql  --socket=/var/lib/SQL/mysql/mysql.sock  dbteam_temp  < /home/web_backup/tbl_sf_weekly_report_mumbai.sql && rm -fv /home/web_backup/tbl_sf_weekly_report_mumbai.sql
ERROR


###########################################
echo "cleaning companymaster_extract_temp.txt,data_city_extract_temp.txt,idgenerator_temp.txt"
rm -fv /tmp/companymaster_extract_temp.txt /tmp/data_city_extract_temp.txt /tmp/idgenerator_temp.txt

sudo mysql -Bse "DROP TABLE IF EXISTS dbteam_temp.tbl_companymaster_extract ; CREATE TABLE dbteam_temp.tbl_companymaster_extract(parentid VARCHAR(255) DEFAULT '', companyname VARCHAR(255),    catidlineage_search TEXT, website_type_flag BIGINT(20)UNSIGNED DEFAULT '0', businesstags BIGINT(20)UNSIGNED DEFAULT '0',PRIMARY KEY(parentid),FULLTEXT KEY idx_ft(catidlineage_search));
SELECT parentid,companyname,catidlineage_search,website_type_flag,businesstags INTO OUTFILE '/tmp/companymaster_extract_temp.txt'   FIELDS TERMINATED BY '||' ENCLOSED BY '\"'   LINES TERMINATED BY '\r\n' FROM db_iro.tbl_companymaster_extradetails  WHERE mask=0 AND freeze=0 AND closedown_flag=0;LOAD DATA INFILE '/tmp/companymaster_extract_temp.txt' INTO  TABLE dbteam_temp.tbl_companymaster_extract FIELDS TERMINATED BY '||' ENCLOSED BY '\"' LINES TERMINATED BY '\r\n'(parentid,companyname,catidlineage_search,website_type_flag,businesstags); CALL sp_outfile_infile_report(); DROP TABLE IF EXISTS dbteam_temp.tbl_datacity_extract; CREATE TABLE dbteam_temp.tbl_datacity_extract (cityname VARCHAR(100) NOT NULL,stdcode VARCHAR(15) DEFAULT NULL,PRIMARY KEY (cityname)) ENGINE=MYISAM DEFAULT CHARSET=latin1; SELECT cityname,stdcode INTO OUTFILE '/tmp/data_city_extract_temp.txt'   FIELDS TERMINATED BY '||' ENCLOSED BY '\"'   LINES TERMINATED BY '\r\n' FROM d_jds.tbl_data_city;
LOAD DATA INFILE '/tmp/data_city_extract_temp.txt' INTO  TABLE dbteam_temp.tbl_datacity_extract FIELDS TERMINATED BY '||' ENCLOSED BY '\"' LINES TERMINATED BY '\r\n'(cityname,stdcode);
DROP TABLE IF EXISTS dbteam_temp.tbl_idgenerator_extract;CREATE TABLE dbteam_temp.tbl_idgenerator_extract ( parentid VARCHAR(100) NOT NULL DEFAULT '', data_city VARCHAR(100) DEFAULT '', PRIMARY KEY parentid (parentid), KEY idx_data_city (data_city)) ENGINE=INNODB DEFAULT CHARSET=latin1;SELECT parentid,data_city INTO OUTFILE '/tmp/idgenerator_temp.txt'   FIELDS TERMINATED BY '||' ENCLOSED BY '\"'   LINES TERMINATED BY '\r\n' db_iro.tbl_id_generator;LOAD DATA INFILE '/tmp/idgenerator_temp.txt' INTO  TABLE dbteam_temp.tbl_datacity_extract FIELDS TERMINATED BY '||' ENCLOSED BY '\"' LINES TERMINATED BY '\r\n'(parentid,data_city);CALL sp_outfile_infile_report();"

sudo mysqldump   dbteam_temp tbl_sf_weekly_report_remotecity   > /tmp/tbl_sf_weekly_report_remotecity.sql  && gzip -fv /tmp/tbl_sf_weekly_report_remotecity.sql 
sudo mysqldump   dbteam_temp cat_data_count_outfile_infile_report_remotecity  > /tmp/cat_data_count_outfile_infile_report_remotecity.sql  && gzip -fv /tmp/cat_data_count_outfile_infile_report_remotecity.sql
sudo mysqldump   db_iro tbl_vertical_display_master   > /tmp/tbl_vertical_display_master.sql  && gzip -fv /tmp/tbl_vertical_display_master.sql  
sudo scp  /tmp/tbl_sf_weekly_report_remotecity.sql.gz /tmp/cat_data_count_outfile_infile_report_remotecity.sql.gz /tmp/tbl_vertical_display_master.sql.gz web_backup@172.29.67.122:/tmp

ERROR
SUCCESS

echo -e "\nprocess completed"
