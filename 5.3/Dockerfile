FROM ubuntu:14.04
MAINTAINER kurotokiya <kurotokiya@gmail.com>
COPY apache-php.sh /usr/local/src/apache-php.sh
WORKDIR /usr/local/src
RUN chmod +x apache-php.sh && ./apache-php.sh
WORKDIR /home/wwwroot
COPY src/ /home/wwwroot/
EXPOSE 80
CMD ["/usr/local/httpd/bin/httpd","-DFOREGROUND"]
