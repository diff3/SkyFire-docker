#!/bin/sh

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

if [ ! -d "$INSTALL_PREFIX/logs" ]; then
   echo "Creating logs directory"
   mkdir -p $INSTALL_PREFIX/logs
fi

if [ ! -d "$INSTALL_PREFIX/data" ]; then
   echo "Creating data directory"
   mkdir -p $INSTALL_PREFIX/data
fi

echo "Switch to build directory"
cd $SOURCE_PREFIX/build

make clean
cmake ../ -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX -DSERVERS=$SERVERS -DSCRIPTS=$SCRIPTS -DTOOLS=$TOOLS -DUSE_SCRIPTPCH=$USE_SCRIPTPCH -DUSE_COREPCH=$USE_COREPCH -DWITH_WARNINGS=$WITH_WARNINGS -DWITH_COREDEBUG=$WITH_COREDEBUG -DCONF_DIR=$CONF_DIR -DLIBSDIR=$LIBSDIR

make -j $(nproc) install
