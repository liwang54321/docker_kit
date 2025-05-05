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
	    curl -fsSL https://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg | sudo apt-key add -


        # Add the repository to Apt sources:
        sudo add-apt-repository \
            "deb https://mirrors.aliyun.com/docker-ce/linux/ubuntu \
            $(lsb_release -cs) \
            stable"
        sudo apt-get update

        sudo apt-get install --no-install-recommends -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
        sudo systemctl restart docker
        sudo usermod -aG docker "${USER}"
    fi
}

function install_nvidia_docker() {
    curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
  && curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
    sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
    sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

    sudo apt-get update
    sudo apt-get install -y nvidia-container-toolkit
}

# https://catalog.ngc.nvidia.com/orgs/nvidia/containers/l4t-jetpack
function jetpack() {
    docker run -it --rm --net=host \
        --runtime nvidia \
        -e DISPLAY=$DISPLAY \
        -v /tmp/.X11-unix/:/tmp/.X11-unix \
        -v /home/"${USER}"/Workspace:/home/"${USER}"/Workspace \
        nvcr.io/nvidia/l4t-jetpack:r35.3.1
}

# https://catalog.ngc.nvidia.com/orgs/nvidia/containers/jetpack-linux-aarch64-crosscompile-x86
function jetpack_cross(){
    docker run -it --privileged --net=host \
        -v /dev/bus/usb:/dev/bus/usb \
        -v /home/"${USER}"/Workspace/:/home/"${USER}"/Workspace \
         nvcr.io/nvidia/jetpack-linux-aarch64-crosscompile-x86:6.1
}

# https://catalog.ngc.nvidia.com/orgs/nvidia/containers/isaac-sim
function isaac-sim()
{
    docker run --name isaac-sim --entrypoint bash -it --runtime=nvidia --gpus all -e "ACCEPT_EULA=Y" --rm --network=host \
        -e "PRIVACY_CONSENT=Y" \
        -v /home/"${USER}"/Workspace:/home/"${USER}"/Workspace \
        -v ~/docker/isaac-sim/cache/ov:/root/.cache/ov:rw \
        -v ~/docker/isaac-sim/cache/pip:/root/.cache/pip:rw \
        -v ~/docker/isaac-sim/cache/glcache:/root/.cache/nvidia/GLCache:rw \
        -v ~/docker/isaac-sim/cache/computecache:/root/.nv/ComputeCache:rw \
        -v ~/docker/isaac-sim/cache/asset_browser:/isaac-sim/exts/isaacsim.asset.browser/cache:rw \
        -v ~/docker/isaac-sim/logs:/root/.nvidia-omniverse/logs:rw \
        -v ~/docker/isaac-sim/data:/root/.local/share/ov/data:rw \
        -v ~/docker/isaac-sim/pkg:/root/.local/share/ov/pkg:rw \
        -v ~/docker/isaac-sim/documents:/root/Documents:rw \
        nvcr.io/nvidia/isaac-sim:4.5.0
}

# https://catalog.ngc.nvidia.com/orgs/nvidia/teams/isaac/containers/ros/tags
function isaac_dev() {
    docker run --name isaac-sim --entrypoint bash -it --runtime=nvidia --gpus all -e "ACCEPT_EULA=Y" --rm --network=host \
        -e "PRIVACY_CONSENT=Y" \
        -v /home/"${USER}"/Workspace:/home/"${USER}"/Workspace \
        -v ~/docker/isaac-sim/cache/ov:/root/.cache/ov:rw \
        -v ~/docker/isaac-sim/cache/pip:/root/.cache/pip:rw \
        -v ~/docker/isaac-sim/cache/glcache:/root/.cache/nvidia/GLCache:rw \
        -v ~/docker/isaac-sim/cache/computecache:/root/.nv/ComputeCache:rw \
        -v ~/docker/isaac-sim/cache/asset_browser:/isaac-sim/exts/isaacsim.asset.browser/cache:rw \
        -v ~/docker/isaac-sim/logs:/root/.nvidia-omniverse/logs:rw \
        -v ~/docker/isaac-sim/data:/root/.local/share/ov/data:rw \
        -v ~/docker/isaac-sim/pkg:/root/.local/share/ov/pkg:rw \
        -v ~/docker/isaac-sim/documents:/root/Documents:rw \
        nvcr.io/nvidia/isaac/ros:x86_64-ros2_humble_79152baed139e9f4258734f3056c263a
}

# https://catalog.ngc.nvidia.com/orgs/nvidia/containers/isaac-lab/tags
function isaac_lab() {
    docker run --name isaac-sim --entrypoint bash -it --runtime=nvidia --gpus all -e "ACCEPT_EULA=Y" --rm --network=host \
        -e "PRIVACY_CONSENT=Y" \
        -v /home/"${USER}"/Workspace:/home/"${USER}"/Workspace \
        -v ~/docker/isaac-sim/cache/ov:/root/.cache/ov:rw \
        -v ~/docker/isaac-sim/cache/pip:/root/.cache/pip:rw \
        -v ~/docker/isaac-sim/cache/glcache:/root/.cache/nvidia/GLCache:rw \
        -v ~/docker/isaac-sim/cache/computecache:/root/.nv/ComputeCache:rw \
        -v ~/docker/isaac-sim/cache/asset_browser:/isaac-sim/exts/isaacsim.asset.browser/cache:rw \
        -v ~/docker/isaac-sim/logs:/root/.nvidia-omniverse/logs:rw \
        -v ~/docker/isaac-sim/data:/root/.local/share/ov/data:rw \
        -v ~/docker/isaac-sim/pkg:/root/.local/share/ov/pkg:rw \
        -v ~/docker/isaac-sim/documents:/root/Documents:rw \
        nvcr.io/nvidia/isaac-lab:2.0.2
}

function v2raya() {
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
    pushd "${top_dir}"/jellyfin >/dev/null 2>&1
    mkdir -p "${top_dir}"/jellyfin/config
    mkdir -p "${top_dir}"/jellyfin/cache
    mkdir -p "${top_dir}"/jellyfin/media
    mkdir -p "${top_dir}"/jellyfin/media2
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
        -v /home/${USER}/Workspace:/home/${USER}/Workspace \
        nvcr.io/drive-coral/driveos-pdk/drive-agx-orin-linux-aarch64-pdk-build-x86:${version}
}

function portainer() {
    docker run -d \
        -p 8000:8000 \
        -p 9443:9443 \
        --name portainer \
        --restart=always \
        -v /var/run/docker.sock:/var/run/docker.sock \
        -v "${top_dir}"/portainer/data:/data \
        portainer/portainer-ce:latest
    echo "portainer is running"
    echo "http://localhost:8000"
}

function heimdall() {
    docker run -d \
        --name=heimdall \
        -e PUID="$(id -u)" \
        -e PGID="$(id -g)" \
        -e TZ=Asia/Shanghai \
        -p 80:80 \
        -p 443:443 \
        -v "${top_dir}"/heimdall/config:/config \
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
        -v /home/"${USER}"/Workspace:/home/"${USER}"/Workspace \
        rti_dev:7.2.0
    echo "rti is running"
}

function filebrowser(){
    # -v ${top_dir}/filebrowser/filebrowser.db:/database/filebrowser.db \
    # -v ${top_dir}/filebrowser/settings.json:/config/settings.json \
    mkdir -p ${top_dir}/filebrowser/root
    docker run \
    -d \
    -v /home/"${USER}"/Workspace:/srv \
    -v "${top_dir}"/filebrowser/database:/database \
    -v "${top_dir}"/filebrowser/config:/config \
    -e PUID=$(id -u) \
    -e PGID=$(id -g) \
    -p 8080:80 \
    filebrowser/filebrowser
}

# https://rustdesk.com/zh-cn/
# https://github.com/rustdesk/rustdesk
# https://rustdesk.com/docs/en/
function rustdesk() {
    pushd ${top_dir}/rustdesk >/dev/null 2>&1
    docker compose up -d
    popd > /dev/null
}

function watchtower() {
    pushd ${top_dir}/watchtower >/dev/null 2>&1
    docker compose up -d
    popd > /dev/null
}

function help() {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  -h, --help     Show this help message and exit"
    echo "  -i, --install                Install docker"
    echo "  -in, --install_nvidia_docker  Install nvidia docker"
    echo "  --v2raya       Run v2raya"
    echo "  --jellyfin     Run jellyfin"
    echo "  --qinglong     Run qinglong"
    echo "  --driveos      Run driveos"
    echo "  --portainer    Run portainer"
    echo "  --heimdall     Run heimdall"
    echo "  --artifacts    Run artifactory"
    echo "  --gitea        Run gitea"
    echo "  --rti          Run rti"
    echo "  --filebrowser  Run filebrowser"
    echo "  --jetpack      Run jetpack"
    echo "  --rustdesk     Run rustdesk"
    echo "  --watchtower   Run watchtower"
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
    -in | install_nvidia_docker)
        install_nvidia_docker
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
    --filebrowser)
        filebrowser
        shift
        ;;
    --jetpack)
        jetpack
        shift
        ;;
    --rustdesk)
        rustdesk
        shift
        ;;
    --watchtower)
        watchtower
        shift
        ;;
    *)
        help
        exit -1
        ;;
    esac
done
