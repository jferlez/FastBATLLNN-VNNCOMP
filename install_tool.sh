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
    # add-apt-repository universe
    apt-get update
    apt-get -y upgrade
    
    apt-get install ca-certificates curl gnupg
    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    chmod a+r /etc/apt/keyrings/docker.gpg
    echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    apt-get update
    apt-get -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    apt -y install python3-pip
    usermod -a -G docker ubuntu
    systemctl restart docker
    USER="ubuntu"
    sudo -u $USER python3 -m pip install --upgrade pip && sudo -u $USER python3 -m pip install tensorflow scipy onnx onnxruntime tf2onnx --no-cache-dir
    chown -R $USER "$SCRIPT_DIR"
fi


# Checkout submodules
sudo -u $USER git submodule update --init --recursive
# sudo -u $USER git submodule update --recursive --remote

cd FastBATLLNN
sudo -u $USER cp ../.hub_token .

sudo -i -u $USER bash -c "cd \"${SCRIPT_DIR}/FastBATLLNN\" && ./dockerbuild.sh"
sudo -i -u $USER bash -c "cd \"${SCRIPT_DIR}/FastBATLLNN\" && ./dockerrun.sh --server --http-port=7999"

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