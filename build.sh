#!/bin/bash
set -e
top_dir=$(
    cd $(dirname $0)
    pwd
)

function driveos() {
    pushd ${top_dir}/driveos > /dev/null 2>&1 
    driveos_version="6.0.12.1"
    if [[ ${http_proxy} != "" ]]; then 
        export proxy="--build-arg http_proxy=${http_proxy} --build-arg https_proxy=${https_proxy}"
    fi
    DOCKER_BUILDKIT=0 docker build --network=host ${proxy} -t driveos:${driveos_version} .
    popd > /dev/null
}

function help() {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  -h, --help     Show this help message and exit"
    echo "  --driveos      Build driveos"
}

while [[ $# -gt 0 ]]; do
    case $1 in
    -h | --help)
        help
        exit 0
        ;;
    --driveos)
        driveos
        shift
        ;;
    *)
        help
        exit -1
        ;;
    esac
done
