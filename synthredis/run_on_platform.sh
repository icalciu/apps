#!/bin/bash

#
# This script is invoked by scripts/sweep.py to run a workload on a specified
# platform.
#

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source ${SCRIPT_DIR}/../../scripts/platforms.sh

function method_default() {

    PROCESS_NAME="^./build/bench"

    kapi=1

    ${PLATFORM} FALSE ${OUTPUT_PREFIX} "${PARAMS}" \
        "./build/bench 1 uniform 300 244 845 100000 1000000 100000 0 0 15000000 ${kapi} ${APP_ARGS}" TRUE
}

pushd ${SCRIPT_DIR}

    method_$METHOD

popd

# Exit and cleanup
set -x

sudo pkill -9 rss-profiler
sudo pkill -9 -f ${PROCESS_NAME}
