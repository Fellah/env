FROM fellah/ubuntu:latest

MAINTAINER Roman Krivetsky <r.krivetsky@gmail.com>

USER root

RUN apt-get -y update &&\
	apt-get -y install python python-pip bash-completion &&\
	pip install awscli

RUN install --directory /etc/bash_completion.d &&\
	cp /usr/local/bin/aws_bash_completer /etc/bash_completion.d

RUN apt-get -y install jq

USER fellah

WORKDIR /home/fellah
