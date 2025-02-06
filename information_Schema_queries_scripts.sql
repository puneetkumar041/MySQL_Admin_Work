	INFORMATION_SCHEMA -- Performance Tuning, Indexing & Security Audit Queries in MySQL

1️⃣ Performance Tuning Queries
--  Find Long-Running Queries

SELECT id, user, host, db, time, state, info 
FROM information_schema.processlist 
WHERE command != 'Sleep' 
ORDER BY time DESC 
LIMIT 10;
--  Use Case: Identifies queries running for too long, causing performance issues.

--  Identify Tables with High Auto-Increment Usage

SELECT table_name, auto_increment, column_type 
FROM information_schema.tables 
WHERE table_schema = 'your_database' 
AND auto_increment IS NOT NULL
ORDER BY auto_increment DESC;
--  Use Case: Helps prevent auto-increment exhaustion issues.

--  Find Unused Indexes (Indexes Not Used in Queries)

SELECT table_name, index_name, stat_value 
FROM mysql.innodb_index_stats 
WHERE stat_name = 'n_diff_pfx01' 
AND stat_value = 0;
--  Use Case: Identifies unnecessary indexes that increase overhead.

--  Identify Tables with High Fragmentation (Optimization Required)

SELECT table_name, data_length, index_length, data_free 
FROM information_schema.tables 
WHERE table_schema = 'your_database' 
AND data_free > 0 
ORDER BY data_free DESC;
--  Use Case: Finds fragmented tables that may need OPTIMIZE TABLE.

--  Identify High Read/Write Tables

SELECT table_schema, table_name, rows_read, rows_inserted, rows_updated, rows_deleted 
FROM information_schema.table_statistics 
ORDER BY rows_read DESC 
LIMIT 10;
--  Use Case: Finds frequently accessed tables that might need partitioning or indexing.

2️⃣ Indexing & Query Optimization
--  List All Indexes in a Database

SELECT table_name, index_name, column_name, seq_in_index, non_unique 
FROM information_schema.statistics 
WHERE table_schema = 'your_database' 
ORDER BY table_name, index_name;
--  Use Case: Provides a clear view of indexing strategies.

--  Find Tables Without Primary Keys (Not Recommended in OLTP Systems)

SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'your_database' 
AND table_name NOT IN 
    (SELECT table_name FROM information_schema.table_constraints WHERE constraint_type = 'PRIMARY KEY');
--  Use Case: Ensures all tables have primary keys for better performance.

--  Identify Columns Without Indexes (Potentially Slow Queries)

SELECT table_name, column_name 
FROM information_schema.columns 
WHERE table_schema = 'your_database' 
AND column_key = '' 
AND data_type IN ('varchar', 'text', 'int', 'bigint');
--  Use Case: Suggests adding indexes to columns frequently used in WHERE clauses.

--  Find Duplicate Indexes (Wastes Space and Slows Performance)

SELECT table_name, index_name, GROUP_CONCAT(column_name ORDER BY seq_in_index) AS indexed_columns 
FROM information_schema.statistics 
WHERE table_schema = 'your_database' 
GROUP BY table_name, index_name 
HAVING COUNT(*) > 1;
--  Use Case: Detects redundant indexes that should be removed.

3️⃣ Security & User Audit Queries
--  List All Users and Their Hosts

SELECT user, host FROM mysql.user;
--  Use Case: Checks which users have access and from which hosts.

--  Find Users with SUPER Privileges (Risky Accounts)

SELECT user, host 
FROM mysql.user 
WHERE super_priv = 'Y';
--  Use Case: Ensures least privilege principle is followed.

--  Check Users with Access to a Specific Database

SELECT grantee, privilege_type 
FROM information_schema.schema_privileges 
WHERE table_schema = 'your_database';
--  Use Case: Verifies who has access to critical databases.

--  Find All Privileges for a Specific User

SHOW GRANTS FOR 'your_user'@'your_host';
--  Use Case: Validates if a user has unnecessary privileges.

--  Find Tables with Public Access (Security Risk!)

SELECT table_schema, table_name 
FROM information_schema.table_privileges 
WHERE grantee = "'%'@'%'" 
AND privilege_type = 'SELECT';
--  Use Case: Prevents unauthorized data exposure.

-- (This query is more complex and requires careful adaptation to your specific needs)

`==============================================================================================`

-- AUTOMATION 
+++++++++++++++++++++++++++++++++++++++++++++++++++

🚀 Full Automation Pipeline for MySQL Monitoring & Optimization
This setup will:
✅ Detect & Log Issues (Long Queries, Unused Indexes, Security Risks)
✅ Automate Index Optimization & Cleanup
✅ Send Alerts via Email & Slack
✅ Kill Idle Connections Automatically


+++++++++++++++++++++++++++++++++++++++++++++++++++
1️⃣ Setup MySQL Monitoring with Cron Jobs
Use cron jobs to execute queries and log results periodically.


🔹 Detect Long-Running Queries & Log to a File
Create a script:
=================
#!/bin/bash
mysql -u root -p'YourPassword' -e "
SELECT id, user, host, db, time, state, info 
FROM information_schema.processlist 
WHERE command != 'Sleep' AND time > 10 
ORDER BY time DESC;" >> /var/log/mysql_long_queries.log
=================
📌 Automate it:
Schedule it every 5 minutes using Cron:

=================
*/5 * * * * /path/to/long_queries.sh
=================

Use Grafana + Prometheus to visualize it.

+++++++++++++++++++++++++++++++++++++++++++++++++++
2️⃣ Automate Index Optimization
🔹 Create an auto-index check script:
=====================
#!/bin/bash
mysql -u root -p'YourPassword' -e "
SELECT table_name, column_name 
FROM information_schema.columns 
WHERE table_schema = 'your_database' 
AND column_key = '' 
AND data_type IN ('varchar', 'text', 'int', 'bigint');" > /var/log/missing_indexes.log

# Send alert if indexes are missing
if [ -s /var/log/missing_indexes.log ]; then
    mail -s "Missing Indexes Alert" your_email@example.com < /var/log/missing_indexes.log
fi
=====================
📌 Automate it:

Run every Sunday at midnight:

=================
0 0 * * 0 /path/to/check_missing_indexes.sh
=================

+++++++++++++++++++++++++++++++++++++++++++++++++++
3️⃣ Kill Idle MySQL Connections Automatically

🔹 Create a script to kill idle connections older than 5 minutes:
=================
#!/bin/bash
mysql -u root -p'YourPassword' -e "
SELECT CONCAT('KILL ', id, ';') 
FROM information_schema.processlist 
WHERE command = 'Sleep' AND time > 300;" | mysql -u root -p'YourPassword'
=================
📌 Automate it:

Run every 30 minutes:

=================
*/30 * * * * /path/to/kill_idle_connections.sh
=================

+++++++++++++++++++++++++++++++++++++++++++++++++++
4️⃣ Security Audit & Alert
🔹 Find High-Risk User Permissions & Email Report
=================
#!/bin/bash
mysql -u root -p'YourPassword' -e "
SELECT user, host, grant_priv, super_priv, file_priv, process_priv 
FROM mysql.user 
WHERE grant_priv = 'Y' OR super_priv = 'Y' OR file_priv = 'Y' OR process_priv = 'Y';" > /var/log/mysql_security_audit.log

mail -s "Security Audit Report" your_email@example.com < /var/log/mysql_security_audit.log
=================
📌 Automate it:

Run every Monday at 3 AM:
=================
0 3 * * 1 /path/to/mysql_security_audit.sh
=================

+++++++++++++++++++++++++++++++++++++++++++++++++++
5️⃣ Slack Alert Integration (Optional)

🔹 Send Security Alerts to Slack
Modify the security script to send alerts via Slack:
=================
#!/bin/bash
WEBHOOK_URL="https://hooks.slack.com/services/YOUR/WEBHOOK/URL"

ALERT_MSG=$(mysql -u root -p'YourPassword' -e "
SELECT user, host, super_priv, grant_priv 
FROM mysql.user 
WHERE super_priv = 'Y' OR grant_priv = 'Y';")

if [ ! -z "$ALERT_MSG" ]; then
    curl -X POST --data-urlencode "payload={\"text\": \"🚨 MySQL Security Alert: \n$ALERT_MSG\"}" $WEBHOOK_URL
fi
=================




For schema analysis ➝ TABLES, COLUMNS, TABLE_CONSTRAINTS
For performance tuning ➝ STATISTICS, PARTITIONS, PROCESSLIST
For security auditing ➝ USER_PRIVILEGES, TABLE_PRIVILEGES
For transaction monitoring ➝ INNODB_TRX
For storage insights ➝ TABLES, TABLESPACES, ENGINES