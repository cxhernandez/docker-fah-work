############################################################
# Dockerfile to run the Folding@home Work Server
############################################################

FROM debian
MAINTAINER Carlos Xavier Hernández <cxh@stanford.edu>

# Set Environment Variables
ENV FAH_WORK_RELEASE="9.0.8-release"
ENV BUILD_ROOT=$HOME/build
ENV CBANG_HOME=$BUILD_ROOT/cbang
ENV LIBFAH_HOME=$BUILD_ROOT/libfah
ENV FAH_WORK_HOME=$BUILD_ROOT/fah-work

# Install dependencies
RUN apt-get update -y && \
    apt-get install -y scons git build-essential libssl-dev \
      libboost-iostreams-dev libboost-system-dev libboost-filesystem-dev \
      libboost-regex-dev python-dev ssl-cert npm nodejs-legacy wget git scons \
      binutils-dev fakeroot valgrind python-twisted-core \
      debian-keyring debian-archive-keyring ca-certificates libssl-dev \
      openssh-client bash

# Setup GitHub OAuth
ARG GITHUB_OAUTH_TOKEN
ENV GITHUB=https://$GITHUB_OAUTH_TOKEN:x-oauth-basic@github.com

# Clone Git Repos
RUN mkdir $BUILD_ROOT && \
    cd $BUILD_ROOT && \
    git clone $GITHUB/CauldronDevelopmentLLC/cbang.git && \
    git clone $GITHUB/FoldingAtHome/libfah.git && \
    git clone $GITHUB/FoldingAtHome/fah-work.git && \
    cd $FAH_WORK_HOME &&  git checkout $FAH_WORK_RELEASE && cd $BUILD_ROOT

# Build repos
RUN scons -C $CBANG_HOME -j4
RUN scons -C $LIBFAH_HOME -j4
RUN scons -C $FAH_WORK_HOME -j4

# Clean up
RUN rm -rf $CBANG_HOME $LIBFAH_HOME && cd $HOME
RUN apt-get remove -y fakeroot valgrind npm git build-essential
RUN apt-get autoremove -y

# Link binary
RUN ln -s $FAH_WORK_HOME/fah-work /usr/local/bin/fah-work

# Copy config.xml
COPY ./config.xml $HOME/config.xml

# Run fah-work
CMD fah-work
