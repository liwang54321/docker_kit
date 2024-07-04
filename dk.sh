#!/bin/bash
set -e
top_dir=$(
    cd $(dirname $0)
    pwd
)

function install_docker() {
    if ! command -v docker &>/dev/null; then
        for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do
            sudo apt-get remove -y --purge $pkg
        done
        sudo apt-get autoremove -y

        # Add Docker's official GPG key:
        sudo apt-get update
        sudo apt-get install ca-certificates curl gnupg -y
        sudo install -m 0755 -d /etc/apt/keyrings
        # curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
        # sudo chmod a+r /etc/apt/keyrings/docker.gpg
	curl -fsSL https://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg | sudo apt-key add -


        # Add the repository to Apt sources:
	sudo add-apt-repository \
	   "deb https://mirrors.aliyun.com/docker-ce/linux/ubuntu \
	   $(lsb_release -cs) \
	   stable"
        # echo \
        #     "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
        # "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" |
        #     sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
        sudo apt-get update

        sudo apt-get install --no-install-recommends -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
        sudo systemctl restart docker
        sudo usermod -aG docker ${USER}
    fi
}

function v2raya() {
    # run v2raya
    docker run -d \
        --restart=always \
        --privileged \
        --network=host \
        --name v2raya \
        -e V2RAYA_LOG_FILE=${top_dir}/v2raya/tmp/v2raya.log \
        -v /lib/modules:/lib/modules:ro \
        -v /etc/resolv.conf:/etc/resolv.conf \
        -v ${top_dir}/v2raya/etc/v2raya:/etc/v2raya \
        mzz2017/v2raya
    echo "v2raya is running"
    echo "login http://localhost:2017"
}

function qinglong() {
    docker run -dit \
        -v ${top_dir}/ql/data:/ql/data \
        -p 5700:5700 \
        --name qinglong \
        --hostname qinglong \
        --restart unless-stopped \
        whyour/qinglong:latest

    echo "qinglong is running"
    echo "http://localhost:5700"
    echo "config repo https://github.com/6dylan6/jdpro"
    echo "add node.js deps: date-fns ds jsdom crypto-js axios, python: requests "
    echo "add env: JD_COOKIE, DY_WASHBEANS=true, DPLH_ADDCAR=true, DPLH_BSHOP=true"
    # echo "ql repo https://github.com/6dylan6/jdpro.git "jd_|jx_|jddj_" "backUp" "^jd[^_]|USER|JD|function|sendNotify""
}

function jellyfin() {
    pushd ${top_dir}/jellyfin >/dev/null 2>&1
    mkdir -p ${top_dir}/jellyfin/config
    mkdir -p ${top_dir}/jellyfin/cache
    mkdir -p ${top_dir}/jellyfin/media
    mkdir -p ${top_dir}/jellyfin/media2
    USER_ID=$(id -u) GROUP_ID=$(id -g) docker compose up -d
    popd >/dev/null
    echo "jellyfin is running"
    echo "http://localhost:8096"
}

function driveos() {
    # local version=6.0.8.0-0003
    local version=6.0.9.0-0007
    docker run -itd \
	--name driveos_${version} \
        --privileged \
        --net=host \
        -v /dev/bus/usb:/dev/bus/usb \
        -v /home/${USER}:/home/nvidia/ \
        nvcr.io/drive-coral/driveos-pdk/drive-agx-orin-linux-aarch64-pdk-build-x86:${version}
}

function portainer() {
    docker run -d \
        -p 8000:8000 \
        -p 9443:9443 \
        --name portainer \
        --restart=always \
        -v /var/run/docker.sock:/var/run/docker.sock \
        -v ${top_dir}/portainer/data:/data \
        portainer/portainer-ce:latest
    echo "portainer is running"
    echo "http://localhost:8000"
}

function heimdall() {
    docker run -d \
        --name=heimdall \
        -e PUID=$(id -u) \
        -e PGID=$(id -g) \
        -e TZ=Asia/Shanghai \
        -p 80:80 \
        -p 443:443 \
        -v ${top_dir}/heimdall/config:/config \
        --restart unless-stopped \
        linuxserver/heimdall:latest
}

function artifacts() {
    docker run \
        --name artifactory \
        -d \
        -p 8081:8081 \
        -p 8082:8082 \
        docker.bintray.io/jfrog/artifactory-cpp-ce:latest
    echo "artifactory is running"
    echo "http://localhost:8081"
}

function gitea() {
    pushd ${top_dir}/gitea >/dev/null 2>&1
    mkdir -p ${top_dir}/gitea/gitea
    mkdir -p ${top_dir}/gitea/postgres
    USER_ID=$(id -u) GROUP_ID=$(id -g) docker compose up -d
    popd > /dev/null
    echo "gitea is running"
    echo "http://localhost:3000"
}

function rti() {
    docker run \
        -d \
        --name rti \
        --network host \
        -v /home/${USER}/Workspace:/home/${USER}/Workspace \
        rti_dev:7.2.0
    echo "rti is running"
}

function help() {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  -h, --help     Show this help message and exit"
    echo "  -i, --install  Install docker"
    echo "  --v2raya       Run v2raya"
    echo "  --jellyfin     Run jellyfin"
    echo "  --qinglong     Run qinglong"
    echo "  --driveos      Run driveos"
    echo "  --portainer    Run portainer"
    echo "  --heimdall     Run heimdall"
    echo "  --artifacts    Run artifactory"
    echo "  --gitea        Run gitea"
    echo "  --rti          Run rti"
    
}

while [[ $# -gt 0 ]]; do
    case $1 in
    -h | --help)
        help
        exit 0
        ;;
    -i | install_docker)
        install_docker
        exit 0
        ;;
    --v2raya)
        v2raya
        shift
        ;;
    --jellyfin)
        jellyfin
        shift
        ;;
    --driveos)
        driveos
        shift
        ;;
    --qinglong)
        qinglong
        shift
        ;;
    --portainer)
        portainer
        shift
        ;;
    --heimdall)
        heimdall
        shift
        ;;
    --rti)
        rti
        shift
        ;;
    *)
        help
        exit -1
        ;;
    esac
done
