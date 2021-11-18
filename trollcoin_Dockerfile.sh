#!/bin/bash
GITHUB='https://github.com/TrollCoin2/TrollCoin-2.0.git'
USER=$(whoami)
USERDIR=$(eval echo ~$USER)
CONF='trollcoin.conf'
DIR='.trollcoin'
RPC_PORT='17000'
P2P_PORT='15000'
#Creates a random password used in Dockerbuild
DPASS=$(tr -cd '[:alnum:]' < /dev/urandom | fold -w11 | head -n1)

#Create Dockerfile
cat << EOF > Dockerfile
FROM ubuntu:14.04
LABEL maintainer $USER
EXPOSE $P2P_PORT
EXPOSE $RPC_PORT
EXPOSE 8887

ENV DISPLAY :0

RUN apt-get update \
 && apt-get -y install \
 make git curl wget libqt5webkit5-dev libqt5gui5 libqt5core5a libqt5dbus5 qttools5-dev qttools5-dev-tools qtcreator libprotobuf-dev protobuf-compiler build-essential libboost-dev libboost-all-dev libboost-system-dev libboost-filesystem-dev libboost-program-options-dev libboost-thread-dev libssl-dev libdb++-dev libstdc++6 libminiupnpc-dev libevent-dev libcurl4-openssl-dev git libpng-dev qrencode libqrencode-dev \
 && apt-get update \
 && apt-get install xauth -y \
 && useradd -rm -d $USERDIR -s /bin/bash -g root -G sudo -u 1000 $USER -p $DPASS

RUN git clone $GITHUB \
 && cd TrollCoin-2.0 \
 && qmake -qt=qt5 "USE_QRCODE=1" "USE_UPNP=1" \
 && make \
 && cd src \
 && make -f makefile.unix USE_UPNP=1 \
 && strip trollcoind

USER $USER
WORKDIR $USERDIR

RUN mkdir -p $USERDIR/$DIR
EOF

