#!/usr/bin/env bash
################################################################
# Copyright 2024 Dong Zhaorui. All rights reserved.
# Author: Dong Zhaorui 847235539@qq.com
# Date  : 2024-05-31
################################################################

HEX_DOCKER_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
function _hex_docker_sub_dir {
    local arg opts
    COMPREPLY=()
    arg="${COMP_WORDS[COMP_CWORD]}"

    if [ -z "$arg" ]; then
        for item in $(ls ${HEX_DOCKER_PATH}/); do
            if [ -d "${HEX_DOCKER_PATH}/${item}" ]; then
                opts="$opts ${item}/"
            fi
        done
    else
        if [ -d "${HEX_DOCKER_PATH}/${arg}" ]; then
            if [ ! ${arg: -1} == "/" ]; then
                dir="${arg}/"
            else
                dir="${arg}"
            fi
        else
            dir=$(dirname ${arg})
            if [ ${dir} == "." ]; then
                dir=""
            else
                dir="${dir}/"
            fi
        fi
        for item in $(ls ${HEX_DOCKER_PATH}/${dir}); do
            if [ -d "${HEX_DOCKER_PATH}/${dir}${item}" ]; then
                opts="$opts ${dir}${item}/"
            fi
        done
    fi

    COMPREPLY=($(compgen -W "$opts" -- ${arg}))
    return 0
}
function hex_docker_cd {
    if [ -z "$1" ]; then
      cd ${HEX_DOCKER_PATH}/
    else
      cd ${HEX_DOCKER_PATH}/$1
    fi

    return 0
}
complete -F "_hex_docker_sub_dir" -o "nospace" "hex_docker_cd"