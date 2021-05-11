#!/bin/bash

#
# This script is invoked by scripts/sweep.py to run a workload on a specified
# platform.
#

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source ${SCRIPT_DIR}/../../scripts/platforms.sh

PROCESS_NAME="^python3 ./dlrm/dlrm_s_pytorch.py"

function method_small() {
    ${PLATFORM} FALSE ${OUTPUT_PREFIX} "${PARAMS}" \
        "python3 ./dlrm/dlrm_s_pytorch.py --print-time \
        --mini-batch-size=1024 --data-size=16384 \
        ${APP_ARGS}" FALSE
}

function method_default() {
    ${PLATFORM} FALSE ${OUTPUT_PREFIX} "${PARAMS}" \
    "python3 ./dlrm/dlrm_s_pytorch.py --mini-batch-size=256 \
        --test-mini-batch-size=16384 --test-num-workers=0 --num-batches=200 \
        --data-generation=random --arch-mlp-bot=512-512-128 --arch-mlp-top=1024-1024-1024-1 \
        --arch-sparse-feature-size=128 --arch-embedding-size=1000000-1000000-1000000-1000000-1000000-1000000-1000000-1000000 \
        --num-indices-per-lookup=100 --arch-interaction-op=dot --numpy-rand-seed=727 \
        --print-freq=1 --print-time \
    ${APP_ARGS}" FALSE
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
