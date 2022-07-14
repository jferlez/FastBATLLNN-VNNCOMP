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

# Checkout submodules
git submodule update --init --recursive
git submodule update --recursive --remote

cd FastBATLLNN
cp ../.hub_token .

./dockerbuild.sh
./dockerrun.sh --server

# make sure server logs get printed to stdout on the host
for (( n=0; n<500; n++ )); do
    if [ -f "${SCRIPT_DIR}/FastBATLLNN/container_results/FastBATLLNN_server_log.out" ]; then
        sleep 5
        cat "${SCRIPT_DIR}/FastBATLLNN/container_results/FastBATLLNN_server_log.out"
        sleep 5
        echo ".................... Install Completed" > "${SCRIPT_DIR}/FastBATLLNN/container_results/FastBATLLNN_server_log.out"
        break
    else
        sleep 1
    fi
done