#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

pushd ${SCRIPT_DIR}

sudo apt install -y libgl1-mesa-glx

if ! test -f "Miniconda3-latest-Linux-x86_64.sh"; then
    wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
fi
bash Miniconda3-latest-Linux-x86_64.sh -b -p ${SCRIPT_DIR}/miniconda3

# Do this everytime
source ${SCRIPT_DIR}/miniconda3/bin/activate
conda init

export QT_QPA_PLATFORM=offscreen
conda env update --file ${SCRIPT_DIR}/environment.yml

conda init --reverse

popd
