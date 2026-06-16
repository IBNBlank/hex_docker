FROM ros:noetic

# install tool packages
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -qqy keyboard-configuration \
    && apt-get install -qqy sudo cmake build-essential software-properties-common \
    && apt-get install -qqy unzip wget git curl librust-libudev-sys-dev clang \
    && apt-get install -qqy psmisc tmux iproute2 vim bash-completion xdotool htop \
    && apt-get install -qqy ca-certificates gpg lsb-release \
    && rm -rf /var/lib/apt/lists/* && apt-get autoremove -qqy && apt-get clean -qqy

# install packages needed
RUN apt-get update \
    && wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | gpg --dearmor - | tee /usr/share/keyrings/kitware-archive-keyring.gpg >/dev/null \
    && echo 'deb [signed-by=/usr/share/keyrings/kitware-archive-keyring.gpg] https://apt.kitware.com/ubuntu/ focal main' | tee /etc/apt/sources.list.d/kitware.list >/dev/null \
    && apt-get update \
    && apt-get install -qqy ros-noetic-desktop-full \
    && apt-get install -qqy ros-noetic-rosbridge-suite \
    && apt-get install -qqy ros-noetic-foxglove-bridge \
    && apt-get install -qqy ros-noetic-joint-state-publisher ros-noetic-joint-state-publisher-gui \
    && DEBIAN_FRONTEND=noninteractive apt-get install -qqy libopencv-dev \
    && rm -rf /var/lib/apt/lists/* && apt-get autoremove -qqy && apt-get clean -qqy

# add user
ENV HOST_USER=hexfellow
RUN useradd --create-home --no-log-init --shell /bin/bash ${HOST_USER}
RUN echo "${HOST_USER} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${HOST_USER} \
    && chmod 0440 /etc/sudoers.d/${HOST_USER}

# copy assistant files
COPY ./assistant/docker-clean /etc/apt/apt.conf.d/docker-clean
COPY --chown=${HOST_USER}:${HOST_USER} ./assistant/bashrc /home/${HOST_USER}/.bashrc

# install cargo
USER ${HOST_USER}
RUN (cd /home/${HOST_USER} && curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y)
RUN /home/${HOST_USER}/.cargo/bin/cargo install cargo-deb
RUN mkdir -p /home/${HOST_USER}/.local/share/bash-completion/completions \
    && /home/${HOST_USER}/.cargo/bin/rustup completions bash       > /home/${HOST_USER}/.local/share/bash-completion/completions/rustup \
    && /home/${HOST_USER}/.cargo/bin/rustup completions bash cargo > /home/${HOST_USER}/.local/share/bash-completion/completions/cargo
USER root

# install python packages needed
RUN wget https://bootstrap.pypa.io/pip/3.8/get-pip.py \
    && python3 get-pip.py \
    && pip3 uninstall numpy -y \
    && pip3 cache purge
USER ${HOST_USER}
RUN pip3 install pygame==2.6.1 pynput==1.7.7 \
    && pip3 install build~=1.2 \
    && pip3 install 'hex-util-msg>=0.1.0a0' \
    && pip3 install 'hex-util-ros>=0.0.1a0' \
    && pip3 install 'eclipse-zenoh==1.3.4' \
    && pip3 install 'hex-util-zenoh>=0.0.1a1' \
    && pip3 cache purge
