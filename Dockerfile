FROM ubuntu:14.04
LABEL maintainer "sidgrip@twitter.com"

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update \
 && apt-get -y install \
    curl libdb5.3++ libminiupnpc-dev libboost-system1.54.0 libboost-filesystem1.54.0 libboost-program-options1.54.0 libboost-thread1.54.0 libqrencode3 libqt5widgets5 libqt5network5 -y

RUN apt-get update
RUN apt-get install xauth -y


EXPOSE 15000
EXPOSE 17000
EXPOSE 8887

ENV DISPLAY :0

RUN useradd -rm -d /home/troll -s /bin/bash -g root -G sudo -u 1000 troll -p coins1!

USER troll
WORKDIR /home/troll
RUN mkdir -p /home/troll/etc
RUN mkdir -p /home/troll/trollcoin
RUN mkdir -p /home/troll/scripts
RUN mkdir -p /home/troll/.trollcoin

RUN chown -R troll:root /home/troll/trollcoin
RUN chown -R troll:root /home/troll/scripts
RUN chown -R troll:root /home/troll/.trollcoin

COPY machine-id /home/troll/etc/
COPY --chown=troll:root TrollCoin /home/troll/trollcoin/
COPY --chown=troll:root trollcoind /home/troll/trollcoin/
COPY --chown=troll:root trollcoin.png /home/troll/scripts/
COPY --chown=troll:root /scripts/copy.sh /home/troll/scripts/
COPY --chown=troll:root /scripts/TrollCoin /home/troll/scripts/
COPY --chown=troll:root /scripts/trollcoind /home/troll/scripts/

RUN ["chmod", "+x", "/home/troll/trollcoin/trollcoind"]
RUN ["chmod", "+x", "/home/troll/trollcoin/TrollCoin"]
RUN ["chmod", "+x", "/home/troll/scripts/copy.sh"]
RUN ["chmod", "+x", "/home/troll/scripts/TrollCoin"]
RUN ["chmod", "+x", "/home/troll/scripts/trollcoind"]