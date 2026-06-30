#!/usr/bin/env bash
################################################################
# Copyright 2025 Dong Zhaorui. All rights reserved.
# Author: Dong Zhaorui 847235539@qq.com
# Date  : 2025-03-26
################################################################

# function: hex_image_build
# args:
# image name (necessary)
# dockerfile path (optional)
hex_image_build() {
  local image_name=""
  local dockerfile_path=""

  while [ $# -gt 0 ]; do
    case $1 in
    -i | --image)
      image_name=$2
      shift 2
      ;;
    -f | --dockerfile)
      dockerfile_path=$2
      shift 2
      ;;
    *)
      echo "Unknown option: $1"
      shift
      ;;
    esac
  done

  if [ -z "${image_name}" ]; then
    echo "Image name is necessary"
    return 1
  fi

  local dockerfile_option=""
  if [ -n "${dockerfile_path}" ]; then
    dockerfile_option="-f ${dockerfile_path}"
  fi

  docker buildx build -t ${image_name} ${dockerfile_option} .
}

# function: hex_container_start
# args:
# image name (necessary)
# container name (necessary)
# host user (necessary)
# display (necessary)
# git_source path (optional)
# hex_ws path (optional)
# rosbag path (optional)
# ssh path (optional)
hex_container_start() {
  local image_name=""
  local container_name=""
  local host_user=""
  local display=""
  local git_source_path=""
  local hex_ws_path=""
  local rosbag_path=""
  local data_path=""
  local ssh_path=""

  while [ $# -gt 0 ]; do
    case $1 in
    -i | --image)
      image_name=$2
      shift 2
      ;;
    -c | --container)
      container_name=$2
      shift 2
      ;;
    -u | --user)
      host_user=$2
      shift 2
      ;;
    -d | --display)
      display=$2
      shift 2
      ;;
    -g | --git_source)
      git_source_path=$2
      shift 2
      ;;
    -w | --hex_ws)
      hex_ws_path=$2
      shift 2
      ;;
    -b | --rosbag)
      rosbag_path=$2
      shift 2
      ;;
    -da | --data)
      data_path=$2
      shift 2
      ;;
    -s | --ssh)
      ssh_path=$2
      shift 2
      ;;
    *)
      echo "Unknown option: $1"
      shift
      ;;
    esac
  done

  if [ -z "${image_name}" ]; then
    echo "Image name is necessary"
    return 1
  fi

  if [ -z "${container_name}" ]; then
    echo "Container name is necessary"
    return 1
  fi

  if [ -z "${host_user}" ]; then
    echo "Host user is necessary"
    return 1
  fi

  if [ -z "${display}" ]; then
    echo "Display is necessary"
    return 1
  fi

  local git_source_option=""
  if [ -n "${git_source_path}" ]; then
    git_source_option="-v ${git_source_path}:/home/hexfellow/git_source:rw"
  fi

  local hex_ws_option=""
  if [ -n "${hex_ws_path}" ]; then
    hex_ws_option="-v ${hex_ws_path}:/home/hexfellow/hex_ws:rw"
  fi

  local rosbag_option=""
  if [ -n "${rosbag_path}" ]; then
    rosbag_option="-v ${rosbag_path}:/home/hexfellow/rosbag:rw"
  fi

  local data_option=""
  if [ -n "${data_path}" ]; then
    data_option="-v ${data_path}:/home/hexfellow/data:rw"
  fi

  local ssh_option=""
  if [ -n "${ssh_path}" ]; then
    ssh_option="-v ${ssh_path}:/home/hexfellow/.ssh:ro"
  fi

  # grant access to /dev/input/event* (needed by evdev) by joining the host's
  # input group; docker only forwards the primary gid, so supplementary groups
  # must be added explicitly via --group-add
  local input_group_option=""
  local input_gid="$(getent group input | cut -d: -f3)"
  if [ -n "${input_gid}" ]; then
    input_group_option="--group-add ${input_gid}"
  fi

  xhost +
  docker run -dit \
    --name=${container_name} \
    --net=host \
    --ipc=host \
    --runtime=nvidia --gpus all \
    -e NVIDIA_DRIVER_CAPABILITIES=display,compute \
    -e DISPLAY=${display} \
    -e QT_X11_NO_MITSHM=1 \
    -e XDG_RUNTIME_DIR=/run/user/$(id -u ${host_user}) \
    --privileged \
    -v /dev:/dev:rw \
    -v /tmp/.X11-unix:/tmp/.X11-unix:rw \
    -u $(id -u ${host_user}):$(id -g ${host_user}) \
    ${input_group_option} \
    -v /run/user/$(id -u ${host_user}):/run/user/$(id -u ${host_user}):rw \
    -w /home/hexfellow \
    ${git_source_option} \
    ${hex_ws_option} \
    ${rosbag_option} \
    ${data_option} \
    ${ssh_option} \
    ${image_name}
}
