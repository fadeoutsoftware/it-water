# root image, base on LTS ubuntu
FROM ubuntu:24.04 AS builder

# image labels
# TODO

# change default shell (from sh to bash)
SHELL ["/bin/bash", "-c"]


ARG DEBIAN_FRONTEND=noninteractive

ENV \
    # set geographical area
    TZ=Europe/Rome \
    # UID of the non-root user 'app'
    APP_UID=1456 

# install system-wide deps 
RUN apt-get update && apt-get install -y \
	git \
	gfortran \
	gcc \
	m4 \
	g++ \
	make \
	mc \
	curl \
	build-essential \
	wget \
	cmake \
	libcurl4-openssl-dev \
	tzdata \
	openjdk-8-jdk \
	bash-completion

# Create a non-root user and group
RUN groupadd \
        --gid=$APP_UID \
        app \
    && useradd -l \
        --uid=$APP_UID \
        --gid=$APP_UID \
        --create-home \
        app  


# activate the application user
USER app
WORKDIR /app

