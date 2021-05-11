#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

pushd ${SCRIPT_DIR}

# Needed if gcc version is not new enough


sudo apt-get update
sudo apt-get install build-essential software-properties-common -y
sudo add-apt-repository ppa:ubuntu-toolchain-r/test -y
sudo apt-get update

sudo apt-get install gcc-snapshot
sudo apt-get update

sudo apt-get install gcc-9 g++-9 -y

sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-5 60 --slave /usr/bin/g++ g++ /usr/bin/g++-5
sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-9 60 --slave /usr/bin/g++ g++ /usr/bin/g++-9
# sudo update-alternatives --config gcc

sudo update-alternatives --set gcc /usr/bin/gcc-9

# To verify if it worked. Just type in your terminal
g++ -v

sudo apt-get -y install opensm perftest srptools libibverbs-dev \
    librdmacm-dev libnuma-dev doxygen mstflint

popd
