ARG ubuntu_version=20.04
FROM ubuntu:${ubuntu_version}
ARG ubuntu_version=20.04

ARG user_name=lw

ENV DEBIAN_FRONTEND noninteractive
ENV TIME_ZONE Asia/Shanghai
ENV LANG C.UTF-8
ENV NV_WORKSPACE /drive

ENV http_proxy=${http_proxy}
ENV https_proxy=${https_proxy}

# update source
RUN apt update && \
    apt install -y --no-install-recommends --reinstall ca-certificates && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY --chown=root:root ./files/sources.list.${ubuntu_version} /etc/apt/sources.list

# timezone
RUN apt clean && apt update && apt upgrade -y && \
    apt-get install -y tzdata && \
    ln -snf /usr/share/zoneinfo/$TIME_ZONE /etc/localtime && \
    echo $TIME_ZONE >/etc/timezone && \
    dpkg-reconfigure -f noninteractive tzdata && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# install apps
RUN apt clean && apt update && \
    apt install -y --no-install-recommends \
    python3-pip python3-dev python-is-python3 \
    fish sudo \
    rsync lrzsz tmux tio xxd \
    git tig neovim \
    sshpass openssh-server nfs-kernel-server \
    build-essential qemu-user-static ninja-build \
    zip unzip pigz \
    libtool libssl-dev libusb-1.0-0-dev usbutils libncurses5-dev ncurses-dev \
    autoconf automake bison device-tree-compiler \
    tftp-hpa tftpd-hpa \
    htop tree wget curl \
    silversearcher-ag \
    gnutls-bin pkg-config gettext mtools bc ctags cpio flex \
    apt-transport-https \
    iputils-ping net-tools iproute2 \
    kmod gnupg2 &&  \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# User
RUN useradd -d "/home/${user_name}" -m \
    -G "sudo,video,audio,adm,dialout" \
    -s "/bin/fish" \
    --no-log-init \
    -p ${user_name} \
    ${user_name}

RUN echo "${user_name} ALL=(ALL) NOPASSWD: ALL" >>/etc/sudoers

WORKDIR /home/${user_name}
USER ${user_name}

# git
RUN git config --global user.name ${user_name} && \
    git config --global user.email "liwang54321@gmail.com" && \
    git config --global core.editor vim && \
    git config --global http.sslVerify false && \
    git config --global http.postBuffer 1048576000

# cmake
RUN sudo apt update && \
    sudo apt-get install -y --no-install-recommends dialog && \
    curl https://apt.kitware.com/kitware-archive.sh | sudo bash && \
    sudo apt update && \
    sudo apt install cmake -y && \
    cmake --version && \
    sudo apt-get autoremove -y && \
    sudo apt-get clean && \
    sudo rm -rf /var/lib/apt/lists/*

# python
RUN pip3 config set global.index-url https://mirrors.aliyun.com/pypi/simple/ && \
    sudo pip3 config set global.index-url https://mirrors.aliyun.com/pypi/simple/ && \
    sudo pip3 install --upgrade conan && \
    conan profile detect --force

# for fish
SHELL ["/bin/fish", "-c"]
RUN curl https://gitee.com/mirrors/oh-my-fish/raw/master/bin/install | fish

SHELL ["/bin/bash", "-c"]
ARG VERSION=6.0.12.1
ARG GCID=39950037
ARG SDK=
ARG OS
ARG RELEASE=
ARG CUDA_VERSION=11.4.30
ARG DRIVER_VERSION
ARG filename
ARG CUDNN_VERSION=8.9.2.19_1.0-1
ARG TRT_RELEASE=8.6.15.19
ARG ea_ga=ga
ARG BUILD_DATE=20240919_1-1

COPY ./files/*.deb /tmp
RUN cd /tmp && \
    sudo dpkg -i ./nv-driveos-repo-pdk-linux-${VERSION}-${GCID}_${VERSION}_amd64.deb && \
    sudo -E apt -f -y install nv-driveos-build-${SDK}-${OS}-${RELEASE}-${GCID} && \
    sudo apt update && \
    sudo apt upgrade -y && \
    sudo dpkg -i ./cuda-repo-ubuntu2004-11-4-local_${CUDA_VERSION}-${DRIVER_VERSION}-1_amd64.deb && \
    sudo cp /var/cuda-repo*/cuda*keyring.gpg /usr/share/keyrings/ && \
    sudo apt-key add /var/cuda-repo-ubuntu2004-11-4-local/${filename}.pub && \
    sudo dpkg -i ./cuda-repo-cross-aarch64-ubuntu2004-11-4-local_${CUDA_VERSION}-1_all.deb && \
    sudo cp /var/cuda-repo*/cuda*keyring.gpg /usr/share/keyrings/ && \
    sudo apt-key add /var/cuda-repo-cross-aarch64-ubuntu2004-11-4-local/${filename}.pub && \
    sudo apt update && \
    sudo apt -y install cuda-toolkit-11-4 -y && \
    sudo apt -y install cuda-cross-aarch64-11-4 -y && \
    sudo rm /var/lib/apt/lists/_var_cuda* && \
    sudo apt --fix-broken install -y && \
    sudo apt autoremove -y && \
    sudo apt install ./cudnn-local-repo-ubuntu2004-${CUDNN_VERSION}.deb && \
    sudo cp /var/cudnn*/cudnn*keyring.gpg /usr/share/keyrings/ && \
    sudo apt-key add /var/cudnn-local-repo-ubuntu2004-${CUDNN_VERSION}/${filename}.pub && \
    sudo apt update && \
    sudo apt install libcudnn8 -y && \
    sudo apt install libcudnn8-dev -y && \
    sudo apt install libcudnn8-samples -y && \
    sudo apt install ./cudnn-local-repo-cross-aarch64-ubuntu2004-${CUDNN_VERSION}.deb && \
    sudo apt-key add /var/cudnn-local-repo-cross-aarch64-ubuntu2004-${CUDNN_VERSION}/${filename}.pub && \
    sudo apt update && \
    sudo apt install libcudnn8-cross-aarch64 -y && \
    sudo dpkg -i nv-tensorrt-repo-ubuntu2004-cuda11.4-trt${TRT_RELEASE}-x86-host-${ea_ga}-${BUILD_DATE}_1-1_amd64.deb && \
    sudo apt-key add /var/nv-tensorrt-repo-ubuntu2004-cuda11.4-trt${TRT_RELEASE}-x86-host-${ea_ga}-${BUILD_DATE}/${filename}.pub && \
    sudo apt update && \
    sudo apt install tensorrt -y && \
    sudo dpkg -i nv-tensorrt-repo-ubuntu2004-cuda11.4-trt${TRT_RELEASE}-d6l-cross-ga-20221229_1-1_amd64.deb && \
    sudo apt-get install tensorrt-cross-aarch64 -y


WORKDIR ${NV_WORKSPACE}
# ENTRYPOINT ["/bin/fish"]
CMD /bin/fish