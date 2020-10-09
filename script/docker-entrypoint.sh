#!/bin/bash

if [ ! -f "$BDS/installed.txt" ]; then

  mkdir -p $DATA_PATH/configs

  cp -R $DEFAULT_CONFIG_PATH/* $DATA_PATH/configs

  ln -sb $DATA_PATH/configs/permissions.json $BDS/permissions.json
  ln -sb $DATA_PATH/configs/whitelist.json $BDS/whitelist.json
  ln -sb $DATA_PATH/configs/server.properties $BDS/server.properties

  if [ ! -f "$SERVER_PATH/bdsx.sh" ]; then
    echo "BDSX is not installed." 
    ls -a
    sleep 30
    exit
  else
    echo "BDSX installed!"
    mkdir -p $DATA_PATH/bdsx
    cp $SERVER_PATH/bdsx/index.js $DATA_PATH/bdsx/index.js
    cp $SERVER_PATH/bdsx/examples.js $DATA_PATH/bdsx/examples.js

    rm -rf $SERVER_PATH/bdsx/index.js $SERVER_PATH/bdsx/examples.js

    ln -sb $DATA_PATH/bdsx/index.js $SERVER_PATH/bdsx/index.js
    ln -sb $DATA_PATH/bdsx/examples.js $SERVER_PATH/bdsx/examples.js
  fi

  if [ ! -d "$DATA_PATH/worlds" ]; then
    mkdir -p $DATA_PATH/worlds
  fi

  ln -sb $DATA_PATH/worlds $BDS/worlds

  if [ ! -d "$DATA_PATH/.bds" ]; then
    mkdir -p $DATA_PATH/.bds
  fi

  touch $BDS/installed.txt

fi

#ln -sb $DATA_PATH/configs/permissions.json $BDS/permissions.json
#ln -sb $DATA_PATH/configs/whitelist.json $BDS/whitelist.json
#ln -sb $DATA_PATH/configs/server.properties $BDS/server.properties
#ln -sb $DATA_PATH/worlds $BDS/worlds

exec "./bdsx.sh"