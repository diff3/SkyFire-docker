#!/bin/sh

escape() {
  local tmp=`echo $1 | sed 's/[^a-zA-Z0-9\s:]/\\\&/g'`
  echo "$tmp"
}

if [ ! -d "$SOURCE_PREFIX" ]; then
   echo "Can't find soure code, cloning"
   git clone -b $BRANCH $SOURCE_CODE
elif [ -d "$SOURCE_PREFIX" ] && [ ! -d "$SOURCE_PREFIX/.git" ]; then
   echo "Source code found, but broken, redownload "
   rm -r $SOURCE_PREFIX
   git clone -b $BRANCH $SOURCE_CODE
elif [ -d "$SOURCE_PREFIX" ] && [ -d "$SOURCE_PREFIX/.git" ]; then
   echo "Source code found, updating"
   cd $SOURCE_PREFIX
   git pull
fi

if [ -d "$SOURCE_PREFIX/build" ]; then
   echo "Removing old build directory"
   rm -r $SOURCE_PREFIX/build
fi

if [ ! -d "$SOURCE_PREFIX/build" ]; then
   echo "Creating build directory"
   mkdir -p $SOURCE_PREFIX/build
fi

if [ ! -d "$INSTALL_PREFIX/data" ]; then
   echo "Creating data directory"
   mkdir -p $INSTALL_PREFIX/data
fi

if [ ! -d "$INSTALL_PREFIX/logs" ]; then
   echo "Creating logs directory"
   mkdir -p $INSTALL_PREFIX/logs
fi

if [ ! -d "$INSTALL_PREFIX/libs" ]; then
   echo "Creating libs directory"
   mkdir -p $INSTALL_PREFIX/libs
fi

echo "Switch to build directory"
cd $SOURCE_PREFIX/build

make clean
cmake ../ -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX -DSERVERS=$SERVERS -DSCRIPTS=$SCRIPTS -DTOOLS=$TOOLS -DUSE_SCRIPTPCH=$USE_SCRIPTPCH -DUSE_COREPCH=$USE_COREPCH -DWITH_WARNINGS=$WITH_WARNINGS -DWITH_COREDEBUG=$WITH_COREDEBUG -DCONF_DIR=$CONF_DIR -DLIBSDIR=$LIBSDIR

make -j $(nproc) install

if [ -f $INSTALL_PREFIX/etc/$AUTH_CONF.conf.dist ]; then
   cp $INSTALL_PREFIX/etc/$AUTH_CONF.conf.dist $INSTALL_PREFIX/etc/$AUTH_CONF.conf
fi

if [ -f $INSTALL_PREFIX/etc/$WORLD_CONF.conf.dist ]; then
   cp $INSTALL_PREFIX/etc/$WORLD_CONF.conf.dist $INSTALL_PREFIX/etc/$WORLD_CONF.conf
fi

# $WORLD_CONF.conf
sed -i -e "/DataDir =/ s/= .*/= $(escape $DATA_DIR)/" $ETC_DIR/$WORLD_CONF.conf
sed -i -e "/LogsDir =/ s/= .*/= $(escape $LOGS_DIR)/" $ETC_DIR/$WORLD_CONF.conf

sed -i -e "/LoginDatabase.Info              =/ s/= .*/= \"$(escape $DB_HOST)\;$MYSQL_PORT\;$(escape $SERVER_DB_USER)\;$(escape $SERVER_DB_PWD)\;$AUTH_DB\"/" $ETC_DIR/$WORLD_CONF.conf
sed -i -e "/WorldDatabase.Info              =/ s/= .*/= \"$(escape $DB_HOST)\;$MYSQL_PORT\;$(escape $SERVER_DB_USER)\;$(escape $SERVER_DB_PWD)\;$WORLD_DB\"/" $ETC_DIR/$WORLD_CONF.conf
sed -i -e "/CharacterDatabase.Info          =/ s/= .*/= \"$(escape $DB_HOST)\;$MYSQL_PORT\;$(escape $SERVER_DB_USER)\;$(escape $SERVER_DB_PWD)\;$CHAR_DB\"/" $ETC_DIR/$WORLD_CONF.conf
# sed -i -e "/LogsDatabase.Info               =/ s/= .*/= \"$(escape $DB_CONTAINER)\;$MYSQL_PORT\;$(escape $SERVER_DB_USER)\;$(escape $SERVER_DB_PWD)\;logs\"/" $ETC_DIR/$WORLD_CONF.conf

sed -i -e "/GameType =/ s/= .*/= $(escape $GAME_TYPE)/" $ETC_DIR/$WORLD_CONF.conf
sed -i -e "/RealmZone =/ s/= .*/= $(escape $REALM_ZONE)/" $ETC_DIR/$WORLD_CONF.conf
sed -i -e "/Motd =/ s/= .*/= $(escape $MOTD_MSG)/" $ETC_DIR/$WORLD_CONF.conf

sed -i -e "/Ra.Enable =/ s/= .*/= $(escape $RA_ENABLE)/" $ETC_DIR/$WORLD_CONF.conf

sed -i -e "/SOAP.Enabled =/ s/= .*/= $(escape $SOAP_ENABLE)/" $ETC_DIR/$WORLD_CONF.conf
sed -i -e "/SOAP.IP =/ s/= .*/= $(escape $SOAP_IP)/" $ETC_DIR/$WORLD_CONF.conf

# $AUTH_CONF.conf
sed -i -e "/LogsDir =/ s/= .*/= $(escape $LOGS_DIR)/" $ETC_DIR/$AUTH_CONF.conf
sed -i -e "/LoginDatabaseInfo =/ s/= .*/= \"$(escape $DB_HOST)\;$MYSQL_PORT\;$(escape $SERVER_DB_USER)\;$(escape $SERVER_DB_PWD)\;$AUTH_DB\"/" $ETC_DIR/$AUTH_CONF.conf
