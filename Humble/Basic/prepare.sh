#!/usr/bin/env bash
################################################################
# Copyright 2025 Dong Zhaorui. All rights reserved.
# Author: Dong Zhaorui 847235539@qq.com
# Date  : 2025-03-26
################################################################

SHELL_DIR=$(dirname "$0")
CURRENT_DIR=$(pwd)
BUILD_FLAG="true"

# docker related variables
image_name=hexfellow/hex-docker-humble-basic
container_name=hex-docker-humble-basic
host_user=$(whoami)
display=$DISPLAY
data_path=/mnt/data
git_source_path=$SHELL_DIR/../../../applications/Humble/Basic/git_source
catkin_ws_path=$SHELL_DIR/../../../applications/Humble/Basic/catkin_ws
ssh_path=$SHELL_DIR/../../../ssh

# Check if the current UID is 1000
if [ "$(id -u)" -ne 1000 ]; then
  echo "This script must be run by a user with UID 1000."
  exit 1
fi

source $SHELL_DIR/../../hex_shell_tools.sh
cd $SHELL_DIR

# build image
if [ "${BUILD_FLAG}" = "true" ]; then
  hex_image_build -i ${image_name}
fi

# start container
hex_container_start \
    --image ${image_name} \
    --container ${container_name} \
    --user ${host_user} \
    --display ${display} \
    --git_source ${git_source_path} \
    --catkin_ws ${catkin_ws_path} \
    --data ${data_path} \
    --ssh ${ssh_path}

cd $CURRENT_DIR
