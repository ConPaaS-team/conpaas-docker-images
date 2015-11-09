FROM phusion/baseimage:latest
MAINTAINER Genc Tato <genc.tato@inria.fr>

#ENV DEBIAN_FRONTEND noninteractive
#RUN apt-get update && \
#    apt-get -y install \
#		python-openssl && \
#    rm -rf /var/lib/apt/lists/* /var/cache/apt/*


RUN rm -f /etc/service/sshd/down
COPY scripts/setkey.sh  /etc/my_init.d/05-setkey
RUN chmod 755 /etc/my_init.d/05-setkey
