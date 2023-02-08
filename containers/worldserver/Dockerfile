FROM debian:bullseye

RUN apt-get clean all && apt-get update
RUN apt-get install -y libmysql++3v5 libssl1.1 libboost-all-dev libncurses-dev mariadb-client

WORKDIR /opt/server/bin
ENTRYPOINT ["./worldserver"]
