#!/bin/bash
php_ext_home=/tmp/php_exts
php_bak_home=${php_ext_home}/baks
php_home=/Data/apps/php

function main()
{
    init_env
    get_php_by_version
    make_install
}

function init_env()
{
    if [ ! -d ${php_ext_home} ];then
        mkdir -p ${php_ext_home} 
    fi

    if [ ! -d ${php_home} ];then
        mkdir -p ${php_home}
    fi
}

#switch php version
function get_php_by_version()
{
    php_source='https://www.php.net/distributions/php-7.2.31.tar.gz'; 
}

function get_php_source()
{
    if [ ! -f ${php_ext_home}/php_source.tar.gz ];then
        cd ${php_ext_home}
        wget -O php_source.tar.gz -P ${php_ext_home} ${php_source}
    fi
}

#for install php
function make_install()
{
    yum install zlib-devel libxml2-devel libjpeg-devel libjpeg-turbo-devel libiconv-devel -y
    yum install freetype-devel libpng-devel gd-devel libcurl-devel libxslt-devel libxslt-devel -y

    get_php_source
    tar -zxvf ${php_ext_home}/php_source.tar.gz ${php_ext_home}/php_source
    cd php_source
    ./configure --with-libdir=lib64 --prefix=${php_home} --with-mysql=mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --with-gd --with-zlib --with-png-dir --with-jpeg-dir --with-iconv --with-curl --with-mcrypt --with-openssl --with-xsl --enable-opcache --enable-inline-optimization --enable-fpm --enable-mbstring --enable-pcntl --enable-soap --enable-sockets --enable-bcmath --with-libxml --with-freetype-dir=/usr/include/freetype2/
    make && make install
    cp php.ini-development ${php_home}/lib/php.ini
    cp ${php_home}/etc/php-fpm.conf.default ${php_home}/etc/php-fpm.conf
    cp ${php_home}/etc/php-fpm.d/www.conf.default ${php_home}/etc/php-fpm.d/www.conf
    cp -R ${php_ext_home}/php_source/sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm
    chmod +x /etc/init.d/php-fpm
    mv ${php_ext_home}/php_source.tar.gz ${php_bak_home}
    ln -s ${php_home}/bin/php /bin/php
    ln -s ${php_home}/bin/phpize /bin/phpize
    ln -s ${php_home}/bin/pecl /bin/pecl
    install_ext
}

#just for install php extensions
function make_install_ext()
{
    tar -zxvf ${php_ext_home}/$1.tar.gz ${php_ext_home}/$1
    cd ${php_ext_home}/$1
    ${php_home}/bin/phpize
    ./configure --with-php-config=${php_home}/bin/php-config
    make
    make install
    echo extension=$1 >> ${php_home}/lib/php.ini
    mv ${php_ext_home}/$1.tar.gz ${php_bak_home}
}

function get_igbinary()
{
    if [ ! -f ${php_ext_home}/igbinary.tar.gz ];then
        wget -O igbinary.tar.gz -P ${php_ext_home} https://pecl.php.net/get/igbinary-3.0.1.tgz    
    fi
}

function get_mongodb()
{
    if [ ! -f ${php_ext_home}/mongodb.tar.gz ];then
        wget -O mongodb.tar.gz -P ${php_ext_home} http://pecl.php.net/get/mongodb-1.5.2.tgz
    fi
}

function get_amqp()
{
    if [ ! -f ${php_ext_home}/amqp.tar.gz ];then
        wget -O amqp.tar.gz -P ${php_ext_home} https://pecl.php.net/get/amqp-1.9.3.tgz
    fi
}

function install_rabbitmq_c()
{
    if [ ! -f ${php_ext_home}/rabbitmqc.tar.gz ];then
        wget -O rabbitmqc.tar.gz -P ${php_ext_home} https://github.com/alanxz/rabbitmq-c/archive/v0.9.0.tar.gz
    fi

    tar -zxvf ${php_ext_home}/rabbitmqc.tar.gz ${php_ext_home}/rabbitmqc
    cd ${php_ext_home}/rabbitmqc
    ${php_home}/bin/phpize
    ./configure --prefix=/Data/apps/rabbitmq_client
    make
    make install
    mv ${php_ext_home}/rabbitmqc.tar.gz ${php_bak_home}

    get_amqp
    tar -zxvf ${php_ext_home}/amqp.tar.gz ${php_ext_home}/amqp
    cd ${php_ext_home}/amqp
    ${php_home}/bin/phpize
    ./configure --with-php-config=${php_home}/bin/php-config --with-librabbitmq-dir=/Data/apps/rabbitmq-client
    make
    make install
    echo extension=amqp >> ${php_home}/lib/php.ini
    mv ${php_ext_home}/amqp.tar.gz ${php_bak_home}
}

function install_composer()
{
    echo 1;    
}

function install_ext()
{
    get_igbinary
    make_install_ext igbinary

    get_mongodb
    make_install_ext mongodb

    install_rabbitmq_c

    install_composer
}

main
