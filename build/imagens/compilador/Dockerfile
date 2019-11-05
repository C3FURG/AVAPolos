FROM ubuntu:bionic

ENV DEBIAN_FRONTEND=noninteractive

RUN set -ex && apt-get update

RUN apt-get install -y --no-install-recommends --no-install-suggests \
  apt-transport-https \
  net-tools \
  ca-certificates \
  curl \
  gnupg-agent \
  software-properties-common \
  apt-rdepends \
  makeself \
  pigz \
  dpkg-dev \
  sshpass \
  nano \
  iputils-ping \
  rsync \
  sudo

RUN useradd --create-home --shell /bin/bash avapolos && \
    echo "ALL ALL=(ALL:ALL) NOPASSWD: ALL" > /etc/sudoers.d/avapolos

#Instalando repositório Docker.
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - && \
    sudo add-apt-repository \
    "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) \
    stable"

RUN apt-get autoclean -y && \
    apt-get autoremove -y && \
    rm -rf /var/lib/{apt,dpkg,cache,log}/ && \
    rm -rf /tmp/* && \
    rm -rf /var/tmp/*

WORKDIR /home/avapolos/

COPY scripts /

RUN chmod 777 /docker-entrypoint.sh
RUN chmod 777 /compilar.sh

ENTRYPOINT [ "/docker-entrypoint.sh" ]

#Docker should be mounted.
#-v /var/run/docker.sock:/run/docker.sock
#-v $(which docker):/bin/docker
