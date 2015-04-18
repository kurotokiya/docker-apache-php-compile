#!/bin/bash

apt-get -y remove --purge apache2 apache2-doc apache2-utils apache2.2-common apache2.2-bin apache2-mpm-prefork apache2-doc apache2-mpm-worker mysql-client mysql-server mysql-common libmysqlclient18 php5 php5-common php5-cgi php5-mysql php5-curl php5-gd libmysql* mysql-*

apt-get -y update

apt-get -y install gcc g++ make cmake autoconf libjpeg8 libjpeg8-dev libpng12-0 libpng12-dev libpng3 libfreetype6 libfreetype6-dev libxml2 libxml2-dev zlib1g zlib1g-dev libc6 libc6-dev libglib2.0-0 libglib2.0-dev bzip2 libzip-dev libbz2-1.0 libncurses5 libncurses5-dev libaio1 libaio-dev curl libcurl3 libcurl4-openssl-dev e2fsprogs libkrb5-3 libkrb5-dev libltdl-dev libidn11 libidn11-dev openssl libssl-dev libtool libevent-dev re2c libsasl2-dev libxslt1-dev patch vim zip unzip tmux htop wget bc expect rsync git sendmail

cd /usr/local/src

wget http://www.us.apache.org/dist/httpd/httpd-2.4.12.tar.bz2
wget http://www.us.apache.org/dist/apr/apr-1.5.1.tar.bz2
wget http://www.us.apache.org/dist/apr/apr-util-1.5.4.tar.bz2
wget http://www.php.net/distributions/php-5.3.29.tar.bz2
wget http://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.14.tar.gz
wget http://downloads.sourceforge.net/project/mcrypt/Libmcrypt/2.5.8/libmcrypt-2.5.8.tar.gz
wget http://downloads.sourceforge.net/project/mhash/mhash/0.9.9.9/mhash-0.9.9.9.tar.gz
wget http://downloads.sourceforge.net/project/mcrypt/MCrypt/2.6.8/mcrypt-2.6.8.tar.gz

tar xf apr-1.5.1.tar.bz2
cd apr-1.5.1
./configure --prefix=/usr/local/apr
make && make install
cd ..
rm -rf apr-1.5.1

tar xf apr-util-1.5.4.tar.bz2
cd apr-util-1.5.4
./configure --prefix=/usr/local/apr-util --with-apr=/usr/local/apr
make && make install
cd ..
rm -rf apr-util-1.5.4

tar xf httpd-2.4.12.tar.bz2
cd httpd-2.4.12
./configure --prefix=/usr/local/httpd --sysconfdir=/etc/httpd --enable-rewrite --enable-ssl --enable-cgi --enable-mods-shared --enable-mudules=most --with-apr=/usr/local/apr --with-apr-util=/usr/local/apr-util
make && make install
cd ..
rm -rf httpd-2.4.12

mkdir -p /home/wwwroot/default
mkdir -p /home/wwwlogs

sed -i "s@AddType\(.*\)Z@AddType\1Z\n    AddType application/x-httpd-php .php .phtml\n    AddType application/x-httpd-php-source .phps@" /etc/httpd/httpd.conf
sed -i 's@^#LoadModule rewrite_module@LoadModule rewrite_module@' /etc/httpd/httpd.conf
sed -i 's@^#LoadModule\(.*\)mod_deflate.so@LoadModule\1mod_deflate.so@' /etc/httpd/httpd.conf
sed -i 's@DirectoryIndex index.html@DirectoryIndex index.html index.php@' /etc/httpd/httpd.conf
sed -i "s@^DocumentRoot.*@DocumentRoot \"/home/wwwroot/default\"@" /etc/httpd/httpd.conf
sed -i "s@^<Directory \"/usr/local/httpd/htdocs\">@<Directory \"/home/wwwroot/default\">@" /etc/httpd/httpd.conf

mkdir /etc/httpd/vhost
cat >> /etc/httpd/vhost/0.conf << EOF
<VirtualHost *:80>
    ServerAdmin admin@localhost
    DocumentRoot "/home/wwwroot/default"
    ServerName localhost
    ErrorLog "/home/wwwlogs/error_apache.log"
    CustomLog "/home/wwwlogs/access_apache.log" common
<Directory "/home/wwwroot/default">
    SetOutputFilter DEFLATE
    Options FollowSymLinks
    Require all granted
    AllowOverride All
    Order allow,deny
    Allow from all
    DirectoryIndex index.html index.php
</Directory>
</VirtualHost>
EOF

cat >> /etc/httpd/httpd.conf <<EOF
ServerTokens ProductOnly
ServerSignature Off
AddOutputFilterByType DEFLATE text/html text/plain text/css text/xml text/javascript
DeflateCompressionLevel 6
SetOutputFilter DEFLATE
Include /etc/httpd/vhost/*.conf
EOF

cp /usr/local/httpd/bin/apachectl /etc/init.d/httpd
service httpd start


tar xzf libiconv-1.14.tar.gz
cd libiconv-1.14
./configure --prefix=/usr/local
[ -n "`cat /etc/issue | grep 'Ubuntu 13'`" ] && sed -i 's@_GL_WARN_ON_USE (gets@//_GL_WARN_ON_USE (gets@' srclib/stdio.h 
[ -n "`cat /etc/issue | grep 'Ubuntu 14'`" ] && sed -i 's@gets is a security@@' srclib/stdio.h 
make && make install
cd ..
rm -rf libiconv-1.14

tar xzf libmcrypt-2.5.8.tar.gz
cd libmcrypt-2.5.8
./configure
make && make install
ldconfig
cd libltdl/
./configure --enable-ltdl-install
make && make install
cd ../..
rm -rf libmcrypt-2.5.8

tar xzf mhash-0.9.9.9.tar.gz
cd mhash-0.9.9.9
./configure
make && make install
cd ..
rm -rf mhash-0.9.9.9

tar xzf mcrypt-2.6.8.tar.gz
cd mcrypt-2.6.8
ldconfig
./configure
make && make install
cd ..
rm -rf mcrypt-2.6.8

tar xf php-5.3.29.tar.bz2
cd php-5.3.29
./configure --prefix=/usr/local/php --with-mysql=mysqlnd --with-curl --with-gd --enable-bcmath --with-openssl --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --with-mhash --with-sqlite3 --with-pdo-sqlite --enable-mbstring --with-zlib --enable-xml --with-libxml-dir=/usr --enable-sockets --with-apxs2=/usr/local/httpd/bin/apxs --with-mcrypt --with-config-file-path=/etc --with-config-file-scan-dir=/etc/php.d --enable-maintainer-zts
make && make install
cp php.ini-production /etc/php.ini
cd ..
rm -rf php-5.3.29

sed -i "s@^memory_limit.*@memory_limit = 64M@" /etc/php.ini
sed -i 's@^output_buffering =@output_buffering = On\noutput_buffering =@' /etc/php.ini
sed -i 's@^;cgi.fix_pathinfo.*@cgi.fix_pathinfo=0@' /etc/php.ini
sed -i 's@^;date.timezone.*@date.timezone = Asia/Shanghai@' /etc/php.ini
sed -i 's@^post_max_size.*@post_max_size = 64M@' /etc/php.ini
sed -i 's@^upload_max_filesize.*@upload_max_filesize = 64M@' /etc/php.ini
sed -i 's@^;upload_tmp_dir.*@upload_tmp_dir = /tmp@' /etc/php.ini
sed -i 's@^max_execution_time.*@max_execution_time = 30@' /etc/php.ini
sed -i 's@^disable_functions.*@disable_functions = passthru,exec,system,chroot,chgrp,chown,shell_exec,ini_alter,ini_restore,dl,openlog,syslog,readlink,symlink,popepassthru,stream_socket_server,fsocket,popen@' /etc/php.ini
sed -i 's@^mysqlnd.collect_memory_statistics.*@mysqlnd.collect_memory_statistics = On@' /etc/php.ini
[ -e /usr/sbin/sendmail ] && sed -i 's@^;sendmail_path.*@sendmail_path = /usr/sbin/sendmail -t -i@' /etc/php.ini

echo "<html><meta charset='utf-8'><h1>おめでとうございます</h1><h4>Apache + PHP 5.3 Works!</h4><h4>by kurotokiya</h4></html>" > /home/wwwroot/default/index.html
echo "<?php phpinfo();" > /home/wwwroot/default/phpinfo.php

rm -rf /usr/local/src/*
service httpd stop
