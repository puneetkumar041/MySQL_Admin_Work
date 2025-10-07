
alter table test.employee add column address varchar(255); 
########################################################################################################################

Steps to Execute

Install Percona Toolkit: If not already installed, install the Percona Toolkit:

########################################################################################################################

sudo apt-get install percona-toolkit   # For Debian/Ubuntu
sudo yum install percona-toolkit      # For RHEL/CentOS
Perform a Dry Run: Test the command to ensure there are no issues before applying:

########################################################################################################################

pt-online-schema-change --alter "ADD COLUMN address VARCHAR(255)" \
--host=localhost \
--user=<your-username> \
--password=<your-password> \
D=test,t=employee \
--dry-run
Execute the Change: If the dry run is successful, remove --dry-run and add --execute:

########################################################################################################################

pt-online-schema-change --alter "ADD COLUMN address VARCHAR(255)" \
--host=localhost \
--user=<your-username> \
--password=<your-password> \
D=test,t=employee \
--execute
Important Notes


########################################################################################################################
Constraints:

Ensure no foreign key constraints exist on the table. The tool does not work with foreign key constraints unless disabled or managed.
Disable triggers during the schema change with --no-triggers if necessary.
Impact on Production:

pt-online-schema-change creates a shadow table and incrementally copies data while applying changes. It's a safer alternative to direct ALTER TABLE operations.
Use with Caution:

Always take a backup of the database before running this tool.
Run the tool during off-peak hours to minimize any potential performance impact.
Benefits of pt-online-schema-change
Performs schema changes with minimal downtime.
Avoids table locks, which can disrupt active operations.
Supports large tables efficiently.