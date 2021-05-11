#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

pushd ${SCRIPT_DIR}

# Redis
##########################
git clone https://github.com/antirez/redis
pushd redis 
    make distclean # important! 
    make -j$(nproc)
    # make test

    # Modify Redis default config file
    # # Disable "save" database
    # sed -e '/save/ s/^#*/#/' -i ./redis.conf
    # echo 'save ""' >> ./redis.conf

    # Use already-provided Redis file
    cp ../redis_memory.conf ./redis.conf
popd

sudo sh -c "echo 'vm.overcommit_memory=1' >> /etc/sysctl.conf"
sudo sysctl vm.overcommit_memory=1

sudo sh -c "echo never > /sys/kernel/mm/transparent_hugepage/enabled"
sudo sh -c "echo 'echo never > /sys/kernel/mm/transparent_hugepage/enabled' >> /etc/rc.local"

sudo sh -c "echo 1024 > /proc/sys/net/core/somaxconn"
sudo sh -c "echo 'echo 1024 > /proc/sys/net/core/somaxconn' >> /etc/rc.local"

# Memtier
##########################
git clone https://github.com/libevent/libevent.git
pushd libevent
    autoreconf -ivf
    ./configure
    make
    # make verify   # (optional)
    sudo make install
popd

sudo apt-get install -y libpcre3-dev  libevent-dev

git clone https://github.com/RedisLabs/memtier_benchmark
pushd memtier_benchmark
    git checkout 1.3.0
    autoreconf -ivf
    ./configure
    make -j$(nproc)
    sudo make install
    sudo ld_config
    sudo ldconfig
popd

# Memcached
##########################
# wget http://www.memcached.org/files/memcached-1.6.6.tar.gz
# tar -xf ./memcached-1.6.6.tar.gz
# pushd memcached-1.6.6
#     ./configure
#     make -j$(nproc)
# popd
# ln -s memcached-1.6.6 memcached
sudo apt-get install memcached
