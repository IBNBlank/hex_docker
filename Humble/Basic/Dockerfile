FROM ros:humble

# install tool packages
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y keyboard-configuration \
    && apt-get install -y sudo cmake build-essential software-properties-common \
    && apt-get install -y unzip wget git curl librust-libudev-sys-dev clang \
    && apt-get install -y psmisc tmux iproute2 vim bash-completion xdotool htop \
    && apt-get install -y ca-certificates gpg libpcap-dev \
    && rm -rf /var/lib/apt/lists/* && apt-get autoremove -y && apt-get clean -y

# install packages needed
RUN apt-get update \
    && wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | gpg --dearmor - | tee /usr/share/keyrings/kitware-archive-keyring.gpg >/dev/null \
    && echo 'deb [signed-by=/usr/share/keyrings/kitware-archive-keyring.gpg] https://apt.kitware.com/ubuntu/ focal main' | tee /etc/apt/sources.list.d/kitware.list >/dev/null \
    && apt-get update \
    && apt-get install -y ros-humble-desktop-full \
    && apt-get install -y ros-humble-rosbridge-suite \
    && apt-get install -y ros-humble-foxglove-bridge \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y libopencv-dev \
    && rm -rf /var/lib/apt/lists/* && apt-get autoremove -y && apt-get clean -y

# add user
ENV HOST_USER=hexfellow
RUN useradd --create-home --no-log-init --shell /bin/bash ${HOST_USER}
RUN echo "${HOST_USER} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${HOST_USER} \
    && chmod 0440 /etc/sudoers.d/${HOST_USER}

# copy assistant files
COPY ./assistant/docker-clean /etc/apt/apt.conf.d/docker-clean
COPY --chown=${HOST_USER}:${HOST_USER} ./assistant/bashrc /home/${HOST_USER}/.bashrc

# install python packages needed
RUN wget https://bootstrap.pypa.io/get-pip.py \
    && python3 get-pip.py \
    && pip3 uninstall numpy -y \
    && pip3 cache purge
USER ${HOST_USER}
RUN pip3 install pygame==2.6.1 pynput==1.7.7 scipy==1.15.3 matplotlib==3.10.3 \
    && pip3 install build~=1.2 \
    && pip3 install 'hex-util-msg>=0.1.0a0' \
    && pip3 install 'hex-util-ros>=0.0.1a0' \
    && pip3 cache purge
