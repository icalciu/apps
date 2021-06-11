#!/bin/bash

#
# This script is invoked by scripts/sweep.py to run a workload on a specified
# platform.
#

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source ${SCRIPT_DIR}/../../scripts/platforms.sh

PROCESS_NAME="^/store/gapbs/pr"

function method_pr_1t() {
    ${PLATFORM} FALSE ${OUTPUT_PREFIX} "${PARAMS}" \
        "OMP_NUM_THREADS=1 /store/gapbs/pr -f /store/gapbs/benchmark/graphs/twitter.sg -i1000 -t1e-4 -n16 ${APP_ARGS}" FALSE
}

function method_pr_2t() {
    ${PLATFORM} FALSE ${OUTPUT_PREFIX} "${PARAMS}" \
        "OMP_NUM_THREADS=2 /store/gapbs/pr -f /store/gapbs/benchmark/graphs/twitter.sg -i1000 -t1e-4 -n16 ${APP_ARGS}" FALSE
}

function method_pr_4t() {
    ${PLATFORM} FALSE ${OUTPUT_PREFIX} "${PARAMS}" \
        "OMP_NUM_THREADS=4 /store/gapbs/pr -f /store/gapbs/benchmark/graphs/twitter.sg -i1000 -t1e-4 -n16 ${APP_ARGS}" FALSE
}

pushd ${SCRIPT_DIR}
    if [ "${PLATFORM}" = "pbmem" ]; then
        sudo pkill -9 -f ${PROCESS_NAME}
    fi

    method_$METHOD
popd

# Exit and cleanup
set -x

sudo pkill -9 -f ${PROCESS_NAME}
sudo pkill -9 rss-profiler
exit
