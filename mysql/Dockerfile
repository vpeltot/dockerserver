FROM ubuntu:14.04
MAINTAINER Adam <adamweb92@gmail.com>
ENV DEBIAN_FRONTEND noninteractive

ENV SRC_DIR=/usr/local/src/

RUN rm -rf /etc/apt/sources.list
COPY ./sources.list /etc/apt/sources.list

# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
RUN groupadd -r mysql && useradd -r -g mysql mysql

RUN grep -r --include '*.list' '^deb ' /etc/apt/ | sed -re 's/^\/etc\/apt\/sources\.list((\.d\/)?|(:)?)//' -e 's/(.*\.list):/\[\1\] /' -e 's/deb http:\/\/ppa.launchpad.net\/(.*?)\/ubuntu .*/ppa:\1/'

COPY ./src/* $SRC_DIR/

RUN set -x \
	#&& apt-key adv --keyserver keyserver.ubuntu.com --recv-keys BA9EF27F \
	&& apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 828AB726 \
  && apt-get -qq -y update \
  && apt-get -qq -y upgrade \
  && apt-get install -y -f \
  libstdc++6 \
  ca-certificates \
  build-essential \
  cmake \
  gcc \
  m4 \
  g++ \
  wget \
  tar \
  dpkg \
	python-dev \
	autotools-dev \
	libicu-dev \
	libncurses5-dev \
  curl \
  make \   
  nano \
  apt-utils \
  && rm -rf /var/lib/apt/lists/*

RUN apt-get remove --purge bison

# install libbison-dev (required for Bison)
RUN cd $SRC_DIR && \
    dpkg -i libbison-dev_2.7.1.dfsg-1_amd64.deb

#install Bison 2.7 (required for PHP)
RUN cd $SRC_DIR && \
    dpkg -i libbison-dev_2.7.1.dfsg-1_amd64.deb


RUN cd $SRC_DIR && \
	tar -xf re2c_0.13.5.orig.tar.gz && \
	chown -R root:root ${SRC_DIR}re2c-0.13.5 && \
	chmod -R 755 ${SRC_DIR}re2c-0.13.5 && \
	cd ${SRC_DIR}re2c-0.13.5 && \
	./configure && \
	make -j"$(nproc)" && \
	make bootstrap && \
	make install


RUN ln -s /usr/include/x86_64-linux-gnu/gmp.h /usr/include/gmp.h

RUN cd ${SRC_DIR} && \
    tar -xf openssl-1.0.2h.tar.gz && \
    cd ${SRC_DIR}openssl-1.0.2h && \
    chmod -R 777 . && \
    ./config --prefix=/usr/local/ssl --openssldir=/usr/local/ssl \
    2>configure.log && \
    make depend && \
    make -j"$(nproc)" 2>make.log && \
    make install 2>install.log

RUN rm -rf /etc/mysql

ENV MYSQL_USER=mysql \
	MYSQL_INSTALL_DIR=/etc/mysql \
	MYSQL_RUN_DIR=/etc/mysql/bin \
	MYSQL_DATA_DIR=/etc/mysql/data \
	MYSQL_LOG_DIR=/etc/mysql/log


ENV BOOST_INSTALL_DIR=/etc/boost/

RUN mkdir -p ${MYSQL_INSTALL_DIR} && \
	cd ${SRC_DIR} && \
	tar -xf mysql-5.7.12.tar.gz && \
	cd ${SRC_DIR}mysql-5.7.12 && \
	chmod -R 777 . && \
	cmake . \
	-DCMAKE_INSTALL_PREFIX=${MYSQL_INSTALL_DIR} \
	-DMYSQL_UNIX_ADDR=/tmp/mysql5712.sock \
	-DWITH_INNOBASE_STORAGE_ENGINE=1 \
	-DMYSQL_DATADIR=${MYSQL_DATA_DIR} \
	-DDEFAULT_CHARSET=utf8 \
	-DDEFAULT_COLLATION=utf8_general_ci \
	-DDOWNLOAD_BOOST=1 \
	-DWITH_BOOST=${BOOST_INSTALL_DIR} \
	-DIGNORE_AIO_CHECK=1 \
	-DBUILD_CONFIG=mysql_release \
	2>cmake.log && \
	make -j"$(nproc)" 2>make.log && \
	make install



RUN cd /etc/mysql && \
	cp support-files/mysql.server /etc/init.d/mysql && \
	chmod +x /etc/init.d/mysql && \
	chown root:root /etc/init.d/mysql && \
	update-rc.d mysql defaults && \
	update-rc.d mysql enable && \
	export PATH=$PATH:/etc/mysql/bin

WORKDIR /etc/mysql/

EXPOSE 3306/tcp
