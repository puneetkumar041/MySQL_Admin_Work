<img width="200" alt="image" src="https://user-images.githubusercontent.com/25247630/219608291-c4ad20a1-b040-46e0-8cef-ca60dc5b76f3.png">


![SHELL SCRIPT](https://img.shields.io/badge/Shell_Script-121011?style=for-the-badge&logo=gnu-bash&logoColor=white)

### Scripts for Day to Day tasks and regular DBA activities 

### various types of Backup 

Mysqldump is a command-line utility that is used to generate the logical backup of the MySQL database. It produces the SQL Statements that can be used to recreate the database objects and data. The command can also be used to generate the output in the XML, delimited text, or CSV format.

*) Full Database Backup

*) Table wise Backup

*) Incremental Backup

*) Database Backup and copy to s3 bucket

*) Backup from multiple servers

 
### Server Monitoring 

Server monitoring helps to monitor your servers and entire infrastructure for critical performance metrics and stay on top of your data center resources. Get in-depth visibility into key performance indicators of your application servers, mail servers, web servers, virtual servers, and database servers to eliminate outages and performance issues

Monitor below parameters with the help of scripts

*) Service Running or not. 

*) MySQL server's RAM usage 

*) MySQL server's Disk utilization

*) MySQL server's CPU utlization 

*) Load on MySQL Server 

### USER management

MySQL server allows us to create numerous users and databases and grant appropriate privileges so that the users can access and manage databases.
The information_schema, mysql, performance_schema, and sys databases are created at installation time and they are storing information about all other databases, system configuration, users, permission and other important data. These databases are necessary for the proper functionality of the MySQL installation.

*) User creation  

*) Grants privileges to Database and to Tables  

*) Resetting Passwords

*) Revoking permissions

*) User migrations

### Archiving 
As the data in MySQL keeps growing, the performance for all the queries will keep decreasing. Typically, queries that originally took milliseconds can now take seconds (or more). That requires a lot of changes (code, MySQL, etc.) to make faster.

The main goal of archiving the data is to increase performance (“make MySQL fast again”), decrease costs and improve ease of maintenance (backup/restore, cloning the replication slave, etc.)

*) Customize archiving script for n number of days 
