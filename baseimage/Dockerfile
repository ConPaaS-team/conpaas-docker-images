FROM phusion/baseimage:latest
MAINTAINER Genc Tato <genc.tato@inria.fr>

RUN rm -f /etc/service/sshd/down
COPY scripts/setkey.sh  /etc/my_init.d/05-setkey
RUN chmod 755 /etc/my_init.d/05-setkey
