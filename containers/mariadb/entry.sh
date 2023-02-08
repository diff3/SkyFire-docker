#!/bin/sh

WORLDDB=https://github.com/TrinityCore/TrinityCore/releases/download/TDB1002.22121/TDB_full_1002.22121_2022_12_20.7z

echo "Starting Initialization of CMaNGOS DB..."

echo "Check database sql files"

if [ ! -d "/opt/etc/TrinityCore" ]; then
	git clone https://github.com/TrinityCore/TrinityCore
else
	cd /opt/etc/TrinityCore
	git pull
	cd /
fi

echo "Removing old database and users"
mysql -u $MYSQL_USERNAME -p$MYSQL_PASSWORD -e "DROP DATABASE IF EXISTS auth;"
mysql -u $MYSQL_USERNAME -p$MYSQL_PASSWORD -e "DROP DATABASE IF EXISTS characters"
mysql -u $MYSQL_USERNAME -p$MYSQL_PASSWORD -e "DROP DATABASE IF EXISTS hotfixes"
mysql -u $MYSQL_USERNAME -p$MYSQL_PASSWORD -e "DROP DATABASE IF EXISTS world"
mysql -u $MYSQL_USERNAME -p$MYSQL_PASSWORD -e "DROP USER IF EXISTS trinity"

echo "Creating databases"
mysql -u $MYSQL_USERNAME -p$MYSQL_PASSWORD -e "CREATE DATABASE auth;"
mysql -u $MYSQL_USERNAME -p$MYSQL_PASSWORD -e "CREATE DATABASE characters"
mysql -u $MYSQL_USERNAME -p$MYSQL_PASSWORD -e "CREATE DATABASE hotfixes"
mysql -u $MYSQL_USERNAME -p$MYSQL_PASSWORD -e "CREATE DATABASE world"

echo "Creat user"
mysql -u $MYSQL_USERNAME -p$MYSQL_PASSWORD -e "CREATE USER 'trinity'@'%' IDENTIFIED BY 'trinity';"

mysql -u $MYSQL_USERNAME -p$MYSQL_PASSWORD -e "GRANT ALL PRIVILEGES ON auth.* to 'trinity'@'%';"
mysql -u $MYSQL_USERNAME -p$MYSQL_PASSWORD -e "GRANT ALL PRIVILEGES ON characters.* to 'trinity'@'%';"
mysql -u $MYSQL_USERNAME -p$MYSQL_PASSWORD -e "GRANT ALL PRIVILEGES ON hotfixes.* to 'trinity'@'%';"
mysql -u $MYSQL_USERNAME -p$MYSQL_PASSWORD -e "GRANT ALL PRIVILEGES ON world.* to 'trinity'@'%';"
mysql -u $MYSQL_USERNAME -p$MYSQL_PASSWORD -e "FLUSH PRIVILEGES;"

echo "Populate database"
mysql -u $MYSQL_USERNAME -p$MYSQL_PASSWORD auth < /opt/etc/TrinityCore/sql/base/auth_database.sql
mysql -u $MYSQL_USERNAME -p$MYSQL_PASSWORD characters < /opt/etc/TrinityCore/sql/base/characters_database.sql

wget $WORLDDB -P /tmp

7z e /tmp/TDB_full_*.7z -o/tmp
mysql -u $MYSQL_USERNAME -p$MYSQL_PASSWORD world < /tmp/*world*.sql
mysql -u $MYSQL_USERNAME -p$MYSQL_PASSWORD hotfixes < /tmp/*hotfixes*.sql

echo "Adding admin user"
# mysql -u $MYSQL_USERNAME -p$MYSQL_PASSWORD auth -e "INSERT INTO account (id, username, sha_pass_hash) VALUES (1, 'admin', '8301316d0d8448a34fa6d0c6bf1cbfa2b4a1a93a');"
# mysql -u $MYSQL_USERNAME -p$MYSQL_PASSWORD auth -e "INSERT INTO account_access (id, gmlevel , RealmID) VALUES (1, 100, -1)";

echo "Update realmd info"
mysql -u $MYSQL_USERNAME -p$MYSQL_PASSWORD auth -e "UPDATE realmlist SET NAME='$REALM_NAME', address='$REALM_ADRESS', port='$REALM_PORT', icon='$REALM_ICON', flag='$REALM_FLAG', timezone='$REALM_TIMEZONE', allowedSecurityLevel='$REALM_SECURITY', population='$REALM_POP'  WHERE id = '1';"

echo "Removing files"
yes | rm -r /tmp/*.sql
