FROM ubuntu:20.04

RUN apt-get clean all && apt-get update
RUN apt-get install -y libmysqlclient-dev libssl1.1 libboost-all-dev

WORKDIR /opt/server/bin
ENTRYPOINT ["./authserver"]
