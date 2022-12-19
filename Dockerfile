FROM debian:stretch-slim as proxy-builder

WORKDIR /proxy/

ARG DEBIAN_FRONTEND=noninteractive

RUN apt update -y -q
RUN apt upgrade -y -q
RUN apt install -y -q g++ make libboost-all-dev dpkg-dev git

RUN git clone https://github.com/MengRao/TCP-UDP-Proxy.git .
RUN git config --global advice.detachedHead false
RUN git checkout 3c0ab60641886c48d223d408dcc81afa50b7a7be
RUN mkdir -p /usr/local/lib
RUN find /usr/lib/ -type f -name 'libboost_*.a' -exec cp -p {} /usr/local/lib/ \;

RUN cd src && make -j $(nproc)

FROM debian:stretch-slim

ENV LINE1="udp 0 127.0.0.1 0"
ENV LINE2=""
ENV LINE3=""
ENV LINE4=""

WORKDIR /proxy/

COPY --from=proxy-builder /root/proxy_server .

ENTRYPOINT echo "$LINE1\n$LINE2\n$LINE3\n$LINE4" >> proxy.conf && ./proxy_server
