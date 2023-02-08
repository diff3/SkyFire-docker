FROM ubuntu:20.04
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get clean all && apt-get update
RUN apt-get install -y libace-dev libmysqlclient-dev libssl1.1 libboost-all-dev

WORKDIR /opt/server/bin
ENTRYPOINT ["./authserver"]
