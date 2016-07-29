# Build the image of ubuntu 14.04 LTS
FROM ubuntu:14.04

#Let the conatiner know that there is no tty
ENV DEBIAN_FRONTEND=noninteractive

# Run apt-get update
RUN apt-get -y -qq update

# Avoid ERROR: invoke-rc.d: policy-rc.d denied execution of start. 
RUN echo "#!/bin/sh\nexit 0" > /usr/sbin/policy-rc.d
RUN apt-get -y -qq upgrade

#docker run ...
# docker exec -i -t <container_name> bash


ARG PUBLIC_IP=172.20.1.24
ARG PUBLIC_HTTP_PORT=8084
ARG PUBLIC_HTTPS_PORT=8443

ARG SRC_DIR=/usr/local/src

ARG HTTPD_VERSION=2.4.20
ENV HTTPD_ROOT_DIR=/etc/apache2
ARG HTTPD_CONF_FILE=/etc/apache2/conf/apache2.conf

ARG PHP_VERSION=5.6.22
ARG PHP_ROOT_DIR=/etc/php-5.6.22
ARG PHP_CGI_WRAPPER=php-5622

ENV FPM_START_FILE=/etc/php-$PHP_VERSION/sbin/php-fpmd

COPY ./src/* $SRC_DIR/

RUN set -x \
    && apt-get install -y -f \
        ca-certificates \
        curl \
        dos2unix \
        zlibc \
        zlib1g \
        zlib1g-dev \
        bzip2 \
        gcc \
        daemon \
        make \
        build-essential \
        g++ \
        gcc \
        nano \
        apt-utils \
        autotools-dev \
        libicu-dev \
        libbz2-dev \
        libpcre3-dev \
        libapr1-dev \
        libaprutil1-dev \
        wget \
        dpkg \
        net-tools \
        libc6 \
        autoconf \
        gettext \
        libkrb5-dev \
        libjpeg62-dev \
        libfreetype6-dev \
        libxml2-dev \
        libcurl4-openssl-dev \
        libpng-dev \
        libxpm-dev \
        libgmp3-dev \
        libc-client2007e-dev \
        libmcrypt-dev \
        libpspell-dev \
        libxslt-dev \
        libmhash-dev \
        && rm -r /var/lib/apt/lists/*

# install libbison-dev (required for Bison)
RUN cd $SRC_DIR && \
    dpkg -i libbison-dev_2.7.1.dfsg-1_amd64.deb

#install Bison 2.7 (required for PHP)
RUN cd $SRC_DIR && \
    dpkg -i libbison-dev_2.7.1.dfsg-1_amd64.deb

#install re2c 0.16 (required for PHP)
RUN cd $SRC_DIR && \
    dpkg -i re2c_0.13.5-1build2_amd64.deb

#(required for PHP)
RUN ln -s /usr/include/x86_64-linux-gnu/gmp.h /usr/include/gmp.h  

#install OpenSSL 1.0.2h
RUN cd $SRC_DIR && \
    tar -xzvf openssl-1.0.2h.tar.gz && \
    cd openssl-1.0.2h && \
    chmod -R 777 . && \
    ./config --prefix=/usr \
    2>configure.log && \
    make depend && \
    make -j"$(nproc)" 2>make.log && \
    make install 2>install.log

#install Apache
RUN cd $SRC_DIR && \
    tar -xzvf httpd-$HTTPD_VERSION.tar.gz && \
    cd httpd-$HTTPD_VERSION && \
    chown -R root:root . && \
    chmod -R 777 . && \
    ./configure \
    --prefix=$HTTPD_ROOT_DIR \
    --exec-prefix=$HTTPD_ROOT_DIR \
    --sysconfdir=$HTTPD_ROOT_DIR/conf \
    --with-mpm=event \
    --enable-mpms-shared=all \
    --with-port=80 \
    --with-pcre=/usr \
    --with-apr=/usr \
    --with-apr-util=/usr \
    --with-ssl=/usr \
    --with-program-name=apache2 \
    --enable-so \
    2>configure.log && \
    make -j"$(nproc)" 2>make.log && \
    make install 2>install.log


RUN sed -i -e 's@#ServerName www.example.com:80@ServerName $PUBLIC_IP:$PUBLIC_HTTP_PORT@g' $HTTPD_CONF_FILE
RUN sed -i -e 's@DocumentRoot "/etc/apache2/htdocs/"@DocumentRoot "/var/www/"@g' $HTTPD_CONF_FILE
RUN sed -i -e 's@<Directory "/etc/apache2/htdocs/">@<Directory "/var/www/">@g' $HTTPD_CONF_FILE

# open ports 8084->80, 8443->443
EXPOSE 8084 8443

#Install PHP depedencies


RUN mkdir -p /etc/php-$PHP_VERSION


RUN cd $SRC_DIR && \
    tar -xvzf php-$PHP_VERSION.tar.gz && \
    chown -R root:root ./php-$PHP_VERSION && \
    chmod -R 777 ./php-$PHP_VERSION && \
    cd php-$PHP_VERSION && \
    ./configure \
    --prefix=$PHP_ROOT_DIR \
    --with-apxs2=$HTTPD_ROOT_DIR/bin/apxs \
    --with-config-file-path=$PHP_ROOT_DIR/etc/ \
    --with-mysqli=mysqlnd \
    --with-pdo-mysql=mysqlnd \
    --with-curl \
    --with-gd \
    --with-gmp \
    --with-kerberos \
    --with-mhash \
    --with-imap \
    --with-imap-ssl \
    --with-mcrypt \
    --with-pspell \
    --with-openssl=/usr \
    --with-xsl=/usr \
    --with-jpeg-dir=/usr \
    --with-png-dir=/usr \
    --with-zlib-dir=/usr \
    --with-xpm-dir=/usr \
    --with-freetype-dir=/usr \
    --with-gettext \
    --with-zlib \
    --with-bz2 \
    --enable-intl \
    --enable-mbstring \
    --enable-zip \
    --enable-wddx \
    --enable-exif \
    --enable-ftp \
    --enable-fpm \
    --enable-bcmath \
    --enable-calendar \
    2>configure.log && \
    make -j"$(nproc)" 2>make.log && \
    make install 2>install.log

RUN cp $SRC_DIR/php-$PHP_VERSION/sapi/fpm/init.d.php-fpm $PHP_ROOT_DIR/sbin/php-fpmd && \
    chmod 0700 $PHP_ROOT_DIR/sbin/php-fpmd


RUN sed -i -e 's@    DirectoryIndex index.html@    DirectoryIndex index.php index.html@g' $HTTPD_CONF_FILE && \
    printf "\n<FilesMatch \"\.php$\">\n \
        \tSetHandler application/x-httpd-php\n\
    </FilesMatch>" >> $HTTPD_CONF_FILE



WORKDIR /etc/apache2/

#Creating testing files into DocumentRoot
RUN rm -rf /var/www/*

RUN mkdir -p /var/www/vhosts && \
    mkdir -p /var/www/vhosts/test1/_logs && \
    mkdir -p /var/www/vhosts/test2/_logs && \

COPY ./public /var/www/vhosts/test1/
COPY ./public /var/www/vhosts/test2/


#Creating PHP-CGI wrappers
RUN mkdir -p /var/www/cgi-bin && \
    touch /var/www/cgi-bin/$PHP_CGI_WRAPPER && \
    printf "#!/bin/bash\n\n \
        exec $PHP_ROOT_DIR/bin/php-cgi\n" >> /var/www/cgi-bin/$PHP_CGI_WRAPPER && \
    chmod -R +x /var/www/cgi-bin/

# Configure with mod_cgi/mod_cgid
RUN sed -i -e 's@#LoadModule cgid_module modules/mod_cgid.so@LoadModule cgid_module modules/mod_cgid.so@g' $HTTPD_CONF_FILE && \
    sed -i -e 's@#LoadModule actions_module modules/mod_actions.so@LoadModule actions_module modules/mod_actions.so@g' $HTTPD_CONF_FILE && \
    printf "\nScriptAlias /php/ /var/www/cgi-bin/\n \
        <Directory /var/www/cgi-bin/>\n \
       \tRequire all granted\n \
    </Directory>" >> $HTTPD_CONF_FILE

# Configure with mod_fcgid
RUN cd $SRC_DIR && \
    wget http://xenia.sote.hu/ftp/mirrors/www.apache.org//httpd/mod_fcgid/$(wget -O- http://xenia.sote.hu/ftp/mirrors/www.apache.org//httpd/mod_fcgid/ | egrep -o 'mod_fcgid-[0-9\.]+.tar.gz' | sort -V  | tail -1) && \
    tar -xf mod_fcgid-[0-9].[0-9].[0-9].tar.gz && \
    cd mod_fcgid-[0-9].[0-9].[0-9] && \
    APXS=/etc/apache2/bin/apxs ./configure.apxs && \
    make -j"$(nproc)" && \
    make install 

# Configure with FPM
RUN find /var/www/vhosts/test*/public/ -exec chown daemon:daemon {} + && \
    sed -i -e 's@#LoadModule proxy_module modules/mod_proxy.so@LoadModule proxy_module modules/mod_proxy.so@g' $HTTPD_CONF_FILE && \
    sed -i -e 's@#LoadModule proxy_fcgi_module modules/mod_proxy_fcgi.so@LoadModule proxy_fcgi_module modules/mod_proxy_fcgi.so@g' $HTTPD_CONF_FILE && \
    echo "include=etc/fpm.d/*.conf" >> $PHP_ROOT_DIR && \
    cp $SRC_DIR/php-$PHP_VERSION/sapi/fpm/init.d.php-fpm $PHP_ROOT_DIR/sbin/php-fpmd && \
    chmod 0700 $PHP_ROOT_DIR/sbin/php-fpmd && \
    find /var/www/vhosts/test*/public/ -exec chown www-data:www-data {} +

# copy test-virtualhost FPM configuration files
COPY ./fpm.d $PHP_ROOT_DIR/etc/

# copy test-virtualhost configuration files
COPY ./vhosts $HTTPD_ROOT_DIR/conf/

RUN sed -i -e 's@Teszt1 - Apache 2.4.20 - PHP 5.6.22 / IP->@Teszt1 - Apache $HTTPD_VERSION - PHP $PHP_VERSION / IP-> $PUBLIC_IP@g' /var/www/vhosts/test1/public/index.html
RUN sed -i -e 's@Teszt1 - Apache 2.4.20 - PHP 5.6.22 / IP->@Teszt2 - Apache $HTTPD_VERSION - PHP $PHP_VERSION / IP-> $PUBLIC_IP@g' /var/www/vhosts/test2/public/index.html

ADD ./run.sh $SRC_DIR/run.sh
RUN chmod +x $SRC_DIR/run.sh

ENTRYPOINT ["/bin/bash","-c","/usr/local/src/run.sh"]
CMD ["-k", "restart"]
CMD ["-D", "FOREGROUND"]

