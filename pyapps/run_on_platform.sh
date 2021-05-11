#!/bin/bash

#
# This script is invoked by scripts/sweep.py to run a workload on a specified
# platform.
#

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source ${SCRIPT_DIR}/../../scripts/platforms.sh

function method_numpy() {

    PROCESS_NAME="^python3 ./numpy-test.py"

    mkdir -p ${SCRIPT_DIR}/outputs

    ${PLATFORM} FALSE ${OUTPUT_PREFIX} "${PARAMS}" \
        "python3 ./numpy-test.py ${APP_ARGS}" FALSE
}

function method_empty() {

    PROCESS_NAME="^python3 ./empty.py"

    mkdir -p ${SCRIPT_DIR}/outputs

    ${PLATFORM} FALSE ${OUTPUT_PREFIX} "${PARAMS}" \
        "python3 ./empty.py ${APP_ARGS}" FALSE
}

function method_matmul() {

    PROCESS_NAME="^python3 ./matmul.py arange"

    mkdir -p ${SCRIPT_DIR}/outputs

    ${PLATFORM} FALSE ${OUTPUT_PREFIX} "${PARAMS}" \
        "python3 ./matmul.py arange ${APP_ARGS}" FALSE
}

function method_matmul_ones() {

    PROCESS_NAME="^python3 ./matmul.py ones"

    mkdir -p ${SCRIPT_DIR}/outputs

    ${PLATFORM} FALSE ${OUTPUT_PREFIX} "${PARAMS}" \
        "python3 ./matmul.py ones ${APP_ARGS}" FALSE
}

function method_mne() {

    PROCESS_NAME="^${SCRIPT_DIR}/miniconda3/envs/mne/bin/python ./mne_data_process.py"

    set -x
    rm -f ${SCRIPT_DIR}/outputs/*

    ${PLATFORM} FALSE ${OUTPUT_PREFIX} "${PARAMS}" \
        "${SCRIPT_DIR}/miniconda3/envs/mne/bin/python ./mne_data_process.py ${APP_ARGS}" FALSE

}

pushd ${SCRIPT_DIR}

    method_$METHOD

popd

# Exit and cleanup
set -x

sudo pkill -9 rss-profiler
sudo pkill -9 -f ${PROCESS_NAME}
