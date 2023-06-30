#!/bin/bash

# Takes a single argument:
#   "v1", a version string.
# 
# This script is executed once to, for example, download any dependencies for 
# your tool, compile any files, or setup any required licenses (if it can be 
# automated). Note that some licences cannot be automatically retrived, so that 
# the tool authors will be be responsible for a manual step prior to running 
# any scripts to get the licenses.

WORKING_DIR="$(pwd)"
SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

cd "$SCRIPT_DIR"

SYSTEM_TYPE=$(uname)
if [ "$SYSTEM_TYPE" = "Darwin" ]; then
    echo ""
    USER=`id -n -u`
else
    add-apt-repository universe
    apt-get update
    apt -y install python3-pip python3.9 python3.9-dev docker.io
    update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.9 1
    usermod -a -G docker ubuntu
    USER="ubuntu"
    sudo -u $USER python3 -m pip install --upgrade pip && sudo -u $USER python3 -m pip -v -v -v install tensorflow scipy onnx onnxruntime tf2onnx
    chown -R $USER "$SCRIPT_DIR"
fi


# Checkout submodules
sudo -u $USER git submodule update --init --recursive
# sudo -u $USER git submodule update --recursive --remote

cd FastBATLLNN
sudo -u $USER cp ../.hub_token .

sudo -i -u $USER bash -c "cd \"${SCRIPT_DIR}/FastBATLLNN\" && ./dockerbuild.sh"
sudo -i -u $USER bash -c "cd \"${SCRIPT_DIR}/FastBATLLNN\" && ./dockerrun.sh --server"

# make sure server logs get printed to stdout on the host
for (( n=0; n<500; n++ )); do
    if [ -f "${SCRIPT_DIR}/FastBATLLNN/container_results/FastBATLLNN_server_log.out" ]; then
        sleep 5
        cat "${SCRIPT_DIR}/FastBATLLNN/container_results/FastBATLLNN_server_log.out"
        chmod 666 "${SCRIPT_DIR}/FastBATLLNN/container_results/FastBATLLNN_server_log.out"
        sleep 30
        sudo -u $USER bash -c "echo \".................... Install Completed\" > \"${SCRIPT_DIR}/FastBATLLNN/container_results/FastBATLLNN_server_log.out\""
        break
    else
        sleep 1
    fi
done