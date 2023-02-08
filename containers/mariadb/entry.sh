#!/bin/sh

echo "Starting Initialization of SkyFire DB..."

echo "Check database sql files"

if [ ! -d "$SOURCE_PREFIX" ]; then
	git clone https://github.com/ProjectSkyfire/SkyFire_548 /opt/etc
else
	cd $SOURCE_PREFIX
	git pull
fi

echo "Removing old database and users"
mysql -u $MYSQL_USERNAME -p$MYSQL_PASSWORD -e "DROP DATABASE IF EXISTS $AUTH_DB;"
mysql -u $MYSQL_USERNAME -p$MYSQL_PASSWORD -e "DROP DATABASE IF EXISTS $CHAR_DB;"
mysql -u $MYSQL_USERNAME -p$MYSQL_PASSWORD -e "DROP DATABASE IF EXISTS $WORLD_DB;"
mysql -u $MYSQL_USERNAME -p$MYSQL_PASSWORD -e "DROP USER IF EXISTS $SERVER_DB_USER;"

echo "Creating databases"
mysql -u $MYSQL_USERNAME -p$MYSQL_PASSWORD -e "CREATE DATABASE $AUTH_DB DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci"
mysql -u $MYSQL_USERNAME -p$MYSQL_PASSWORD -e "CREATE DATABASE $CHAR_DB DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci"
mysql -u $MYSQL_USERNAME -p$MYSQL_PASSWORD -e "CREATE DATABASE $WORLD_DB DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci"

echo "Creat user"
mysql -u $MYSQL_USERNAME -p$MYSQL_PASSWORD -e "CREATE USER '$SERVER_DB_USER'@'$SERVER_DB_USERIP' IDENTIFIED BY '$SERVER_DB_PWD';"

mysql -u $MYSQL_USERNAME -p$MYSQL_PASSWORD -e "GRANT ALL PRIVILEGES ON $AUTH_DB.* to '$SERVER_DB_USER'@'$SERVER_DB_USERIP';"
mysql -u $MYSQL_USERNAME -p$MYSQL_PASSWORD -e "GRANT ALL PRIVILEGES ON $CHAR_DB.* to '$SERVER_DB_USER'@'$SERVER_DB_USERIP';"
mysql -u $MYSQL_USERNAME -p$MYSQL_PASSWORD -e "GRANT ALL PRIVILEGES ON $WORLD_DB.* to '$SERVER_DB_USER'@'$SERVER_DB_USERIP';"
mysql -u $MYSQL_USERNAME -p$MYSQL_PASSWORD -e "FLUSH PRIVILEGES;"

echo "Populate database"
mysql -u $MYSQL_USERNAME -p$MYSQL_PASSWORD auth < $SOURCE_PREFIX/sql/base/auth_database.sql
mysql -u $MYSQL_USERNAME -p$MYSQL_PASSWORD characters < $SOURCE_PREFIX/sql/base/characters_database.sql

echo "Download database"
wget $DB_URL -P /tmp
unzip /tmp/SFDB_full_548.21.0_2021_02_07.zip -d /tmp

find /tmp/main_db/world/SFDB_full_548.21.0_2021_01_07.sql -type f | xargs sed -i  's/utf8mb4_0900_ai_ci/utf8mb4_unicode_ci/g'
# find /tmp/main_db/world/SFDB_full_548.21.0_2021_01_07.sql -type f | xargs sed -i  's/CHARSET=utf8mb4/CHARSET=utf8/g'

mysql -u $MYSQL_USERNAME -p$MYSQL_PASSWORD world < /tmp/main_db/world/SFDB_full_548.21.0_2021_01_07.sql

echo "Updates"
cat $SOURCE_PREFIX/sql/updates/auth/*.sql > /tmp/auth.sql
cat $SOURCE_PREFIX/sql/updates/characters/*.sql > /tmp/characters.sql
cat $SOURCE_PREFIX/sql/updates/world/*.sql > /tmp/world.sql

mysql -u $MYSQL_USERNAME -p$MYSQL_PASSWORD auth < /tmp/auth.sql
mysql -u $MYSQL_USERNAME -p$MYSQL_PASSWORD characters < /tmp/characters.sql
mysql -u $MYSQL_USERNAME -p$MYSQL_PASSWORD world < /tmp/world.sql

echo "Adding admin user"
# mysql -u $MYSQL_USERNAME -p$MYSQL_PASSWORD auth -e "INSERT INTO account (id, username, sha_pass_hash) VALUES (1, 'admin', '8301316d0d8448a34fa6d0c6bf1cbfa2b4a1a93a');"
# mysql -u $MYSQL_USERNAME -p$MYSQL_PASSWORD auth -e "INSERT INTO account_access (id, gmlevel , RealmID) VALUES (1, 100, -1)";

echo "Update realmd info"
# mysql -u $MYSQL_USERNAME -p$MYSQL_PASSWORD auth -e "UPDATE realmlist SET NAME='$REALM_NAME', address='$REALM_ADRESS', port='$REALM_PORT', icon='$REALM_ICON', flag='$REALM_FLAG', timezone='$REALM_TIMEZONE', allowedSecurityLevel='$REALM_SECURITY', population='$REALM_POP'  WHERE id = '1';"

echo "Removing files"
yes | rm -r /tmp/*.sql
