FROM mariadb:latest

RUN apt-get update && apt-get -y install git tree unzip wget

# RUN echo "printenv" > /docker-entrypoint-initdb.d/enter.sh
# RUN echo "tree /opt" > /docker-entrypoint-initdb.d/enter.sh
COPY entry.sh /docker-entrypoint-initdb.d/
