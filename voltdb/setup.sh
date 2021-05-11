#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# VoltDB
##########################

sudo sh -c "echo never > /sys/kernel/mm/transparent_hugepage/enabled"
sudo sh -c "echo never > /sys/kernel/mm/transparent_hugepage/defrag"

sudo sh -c "echo 'echo never > /sys/kernel/mm/transparent_hugepage/enabled' >> /etc/rc.local"
sudo sh -c "echo 'echo never > /sys/kernel/mm/transparent_hugepage/defrag' >> /etc/rc.local"

sudo apt-get -y install ant build-essential ant-optional openjdk-8-jdk python cmake \
    valgrind ntp ccache git-completion git-core git-svn git-doc \
    git-email python-httplib2 python-setuptools python-dev apt-show-versions

pushd ${SCRIPT_DIR}
    git clone https://github.com/VoltDB/voltdb
    cd voltdb

    ant clean
    ant -Djmemcheck=NO_MEMCHECK

popd

# Copy our modified files to appropriate location in voltdb checkout
cp ${SCRIPT_DIR}/run.sh ${SCRIPT_DIR}/voltdb/tests/test_apps/tpcc/
cp ${SCRIPT_DIR}/MyLoader.java ${SCRIPT_DIR}/voltdb/tests/test_apps/tpcc/client/com/
cp ${SCRIPT_DIR}/MyTPCC.java ${SCRIPT_DIR}/voltdb/tests/test_apps/tpcc/client/com/
