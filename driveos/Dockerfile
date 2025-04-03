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

COPY ./files/*.deb /tmp/

ARG VERSION=6.0.12.1
ARG GCID=39950037
ARG SDK=pdk
ARG OS=linux
ARG CUDA_VERSION=11.4.30
ARG DRIVER_VERSION=535.161.07
ARG filename_amd64=9A8C2CA0
ARG filename_cross=4AF3F4E2
ARG CUDNN_VERSION=8.9.2.19
ARG filename_cudnn=FFDCDC6C
ARG filename_cudnn_cross=E7EA4BEF
ARG TRT_RELEASE=8.6.15.19
ARG ea_ga=ga
ARG BUILD_DATE=20240919_1-1
ARG filename_trt=71e1174e

RUN cd /tmp && \
    sudo mkdir -p /${NV_WORKSPACE} && \
    sudo chown ${user_name}:${user_name} /${NV_WORKSPACE} && \
    touch /${NV_WORKSPACE}/.nvlicense_${VERSION} && \
    sudo dpkg -i ./nv-driveos-repo-pdk-linux-${VERSION}-${GCID}_${VERSION}_amd64.deb && \
    sudo apt update && \
    sudo -E apt -f -y install nv-driveos-build-${SDK}-${OS}-${VERSION}-${GCID} && \
    sudo apt upgrade -y && \
    sudo dpkg -i ./cuda-repo-ubuntu2004-11-4-local_${CUDA_VERSION}-${DRIVER_VERSION}-1_amd64.deb && \
    sudo cp /var/cuda-repo*/cuda*keyring.gpg /usr/share/keyrings/ && \
    sudo apt-key add /var/cuda-repo-ubuntu2004-11-4-local/${filename_amd64}.pub && \
    sudo dpkg -i ./cuda-repo-cross-aarch64-ubuntu2004-11-4-local_${CUDA_VERSION}-1_all.deb && \
    sudo cp /var/cuda-repo*/cuda*keyring.gpg /usr/share/keyrings/ && \
    sudo apt-key add /var/cuda-repo-cross-aarch64-ubuntu2004-11-4-local/${filename_cross}.pub && \
    sudo apt update && \
    sudo apt -y install cuda-toolkit-11-4 -y && \
    sudo apt -y install cuda-cross-aarch64-11-4 -y && \
    sudo rm /var/lib/apt/lists/_var_cuda* && \
    sudo apt --fix-broken install -y && \
    sudo apt autoremove -y && \
    sudo apt install ./cudnn-local-repo-ubuntu2004-${CUDNN_VERSION}_1.0-1_amd64.deb && \
    sudo cp /var/cudnn*/cudnn*keyring.gpg /usr/share/keyrings/ && \
    sudo apt-key add /var/cudnn-local-repo-ubuntu2004-${CUDNN_VERSION}/${filename_cudnn}.pub && \
    sudo apt update && \
    sudo apt install libcudnn8 -y && \
    sudo apt install libcudnn8-dev -y && \
    sudo apt install libcudnn8-samples -y && \
    sudo apt install ./cudnn-local-repo-cross-aarch64-ubuntu2004-${CUDNN_VERSION}_1.0-1_all.deb && \
    sudo apt-key add /var/cudnn-local-repo-cross-aarch64-ubuntu2004-${CUDNN_VERSION}/${filename_cudnn_cross}.pub && \
    sudo cp /var/cudnn*/cudnn*keyring.gpg /usr/share/keyrings/ && \
    sudo apt update && \
    sudo apt install libcudnn8-cross-aarch64 -y && \
    sudo dpkg -i nv-tensorrt-repo-ubuntu2004-cuda11.4-trt${TRT_RELEASE}-x86-host-${ea_ga}-${BUILD_DATE}_1-1_amd64.deb && \
    sudo apt-key add /var/nv-tensorrt-repo-ubuntu2004-cuda11.4-trt${TRT_RELEASE}-x86-host-${ea_ga}-${BUILD_DATE}/${filename_trt}.pub && \
    sudo apt update && \
    sudo apt install tensorrt -y && \
    sudo dpkg -i nv-tensorrt-repo-ubuntu2004-cuda11.4-trt${TRT_RELEASE}-d6l-cross-${ea_ga}-${BUILD_DATE}_amd64.deb && \
    sudo apt update && \
    sudo apt-get install tensorrt-cross-aarch64 -y && \
    sudo apt install -y libglu1-mesa python3-jinja2 python3-jsonschema python3-numpy libdrm-dev libgl1-mesa-dev \
        libglu1-mesa-dev libx11-dev libxcursor-dev libxinerama-dev libxrandr-dev \
        libxxf86vm-dev mesa-common-dev graphviz libqt5core5a libqt5qml5 libqt5svg5 libxcursor1 \
        python3-crypto python3-pycryptodome python3-matplotlib python3-pil python3-prompt-toolkit \
        python3-pygments python3-regex python3-tabulate python3-tk libqt5quick5 qml-module-qtquick-layouts \
        qml-module-qtquick2  qml-module-qtquick-window2 && \
    sudo dpkg -i ./driveworks* && \
    sudo apt install -y libxcb-cursor0 && \
    sudo dpkg -i ./NVIDIA_Nsight_Graphics_DRIVE_NDA_2024.2.24309.deb && \
    sudo dpkg -i ./NsightSystems-linux-nda-2024.7.2.98-3515348.deb && \
    sudo apt update &&\
    sudo apt autoremove -y && \
    sudo apt clean && \
    sudo rm -rf /var/lib/apt/lists/* && \
    sudo rm /tmp/* -rf && \
    sudo rm /var/nv* -rf


WORKDIR ${NV_WORKSPACE}
# ENTRYPOINT ["/bin/fish"]
CMD /bin/fish