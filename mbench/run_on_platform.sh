#!/bin/bash

#
# This script is invoked by scripts/sweep.py to run a workload on a specified
# platform.
#

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source ${SCRIPT_DIR}/../../scripts/platforms.sh

PROCESS_NAME="^./benchmarks/mbench-latency.out"

pushd ${SCRIPT_DIR}/../../pbmem

    if [ "${PLATFORM}" = "pbmem" ]; then
        sudo pkill -9 ${PROCESS_NAME}
    fi

    ${PLATFORM} FALSE ${OUTPUT_PREFIX} "${PARAMS}" \
        "./benchmarks/mbench-latency.out ${APP_ARGS}" FALSE

popd

# Exit and cleanup
set -x

sudo pkill -9 rss-profiler
exit
