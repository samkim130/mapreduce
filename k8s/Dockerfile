FROM ubuntu:18.04

RUN apt-get -y update
RUN apt-get install -y ca-certificates zookeeper libzookeeper-mt2 zookeeperd zookeeper-bin libzookeeper-mt-dev libssl-dev
RUN apt-get install -y python3.7 python3.7-dev
RUN apt-get install -y net-tools iputils-ping tcpdump curl
RUN apt-get install -y valgrind

WORKDIR /app

# copy any libs from host
COPY cmake/build/lib /usr/local/lib/

# copy build
COPY cmake/build/ .

CMD [ "bash", "./run.sh" ]
# CMD [ "tail", "/dev/null", "-f" ]

