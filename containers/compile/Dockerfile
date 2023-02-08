FROM ubuntu:20.04
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get -y install --no-install-recommends \
clang \
cmake \
g++ \
gcc \
git \
libace-dev \
libboost-all-dev \
libbz2-dev \
libmysqlclient-dev \
libncurses-dev \
libreadline-dev \
libssl-dev \
make \
mariadb-client \
mariadb-server \
ntp \
tzdata \
vim

RUN update-alternatives --install /usr/bin/cc cc /usr/bin/clang 100
RUN update-alternatives --install /usr/bin/c++ c++ /usr/bin/clang 100

WORKDIR /opt/etc

COPY --chmod=755 entry.sh /

ENTRYPOINT ["/entry.sh"]
