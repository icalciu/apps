#!/bin/bash

#
# This script is invoked by scripts/sweep.py to run a workload on a specified
# platform.
#
# The method_* functions correspond to method names in scripts/apps.py
#

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source ${SCRIPT_DIR}/../../scripts/platforms.sh

PORT=$((30000 + ${UNIQUE_ID}))

set -x
# Parse the METHOD to extract KVS_NAME
if [[ "${METHOD}" == *"redis"* ]]; then
    KVS_NAME="redis"
    METHOD=${METHOD:6}
else
    KVS_NAME="memcached"
    METHOD=${METHOD:10}
fi
set +x

ulimit -n 1048576
if [ "${KVS_NAME}" = "redis" ]; then
    PROCESS_NAME="^./redis/src/redis-server"
    EXTRA_MEMTIER_ARGS=
elif [ "${KVS_NAME}" = "memcached" ]; then
    PROCESS_NAME="^memcached"
    EXTRA_MEMTIER_ARGS="-P memcache_text"
fi

pushd ${SCRIPT_DIR}

    sudo pkill -9 rss-profiler
    sudo pkill -9 -f ${PROCESS_NAME}

    if [ "${KVS_NAME}" = "redis" ]; then
        ${PLATFORM} TRUE ${OUTPUT_PREFIX} "${PARAMS}" \
            "./redis/src/redis-server ./redis/redis.conf --port $PORT $APP_ARGS" FALSE
    elif [ "${KVS_NAME}" = "memcached" ]; then
        ${PLATFORM} TRUE ${OUTPUT_PREFIX} "${PARAMS}" \
            "memcached -u $USER -v -m 8192 -p $PORT $APP_ARGS" FALSE
    fi

popd


echo $(pgrep --parent ${!})

echo Waiting for KVS ${KVS_NAME} to start
sleep 5

set -x

function method_random_tiny() {
    memtier_benchmark -p $PORT -t 10 -n 400 --ratio 1:1 -c 20 -x 1 --key-pattern R:R --hide-histogram --distinct-client-seed -d 300 --pipeline=1000 ${EXTRA_MEMTIER_ARGS}
}

function method_random_4gb() {
    memtier_benchmark -p $PORT -t 10 -n 400000 --ratio 1:1 -c 20 -x 1 --key-pattern R:R --hide-histogram --distinct-client-seed -d 300 --pipeline=1000 ${EXTRA_MEMTIER_ARGS}
}

function method_seq_0.13gb() {
    memtier_benchmark -p $PORT -t 10 -n 400000 --ratio 1:1 -c 20 -x 1 --key-pattern S:S --hide-histogram --distinct-client-seed -d 300 --pipeline=1000 ${EXTRA_MEMTIER_ARGS}
}

function method_seq_1_5gb() {
    memtier_benchmark -p $PORT -t 10 -n 8000000 --ratio 1:1 -c 20 -x 1 --key-pattern S:S --hide-histogram --distinct-client-seed -d 300 --pipeline=1000 ${EXTRA_MEMTIER_ARGS}
}

function method_random_2gb() {
    memtier_benchmark -p $PORT -t 10 -n 40000 --ratio 1:1 -c 20 -x 1 --key-pattern R:R --hide-histogram --distinct-client-seed -d 300 --pipeline=1000 ${EXTRA_MEMTIER_ARGS}
}

method_$METHOD

sleep 5

# Exit and cleanup
sudo pkill -9 -f ${PROCESS_NAME}
sudo pkill -9 rss-profiler
