FROM ubuntu:20.04
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get -y install --no-install-recommends \
# build-essential \
clang \
cmake \
# libmysqlclient-dev \
g++ \
gcc \
# gcc-7 \
git \
libace-dev \
libboost-all-dev \
libbz2-dev \
# libgcc-7-dev \
# libmariadb-dev \
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
