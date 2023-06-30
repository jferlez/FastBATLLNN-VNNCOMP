#!/bin/bash

# Takes four arguments in this order:
#   "v1";
#   benchmark identifier string such as "acasxu";
#   path to the .onnx file;
#   path to .vnnlib file.
#
# This script prepares the benchmark for evaluation (for example converting the onnx file 
# to pytorch or reading in the vnnlib file to generate c++ source code for the specific 
# property and compiling the code using gcc. You can also use this script to ensure that 
# the system is in a good state to measure the next benchmark (for example, there are no 
# zombie processes from previous runs executing and the GPU is available for use). This 
# script should not do any analysis. The benchmark name is provided, as per benchmark 
# settings are permitted (per instance settings are not, so do NOT use the onnx filename 
# or vnnlib filename to customize the verification tool settings). If you want to skip a 
# benchmark category entirely, you can have prepare_instance.sh return a nonzero value 
# (the category is passed in as a command=line argument).
#
# ** NB: ** If you want to skip a benchmark category entirely, you can have prepare_instance.sh 
# return a nonzero value (the category is passed in as a command=line argument).

WORKING_DIR="$(pwd)"
SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

BENCHMARK=$2
ONNXFILE="$3"
VNNLIBFILE="$4"

# Skip anything that isn't a TLL
if [ "$BENCHMARK" != "tllverifybench" ]; then
    exit 1
fi

export PYTHONPATH="${SCRIPT_DIR}/FastBATLLNN:${SCRIPT_DIR}/FastBATLLNN/HyperplaneRegionEnum:${SCRIPT_DIR}/FastBATLLNN/TLLnet:${SCRIPT_DIR}/nnenum/src/nnenum"

sleep 5

"${SCRIPT_DIR}/FastBATLLNN/dockerrun.sh" --server --http-port=7999

sleep 30

python3 -m FastBATLLNNClient setProblem "$ONNXFILE" "$VNNLIBFILE"

# make sure server logs get printed to stdout on the host
cat "${SCRIPT_DIR}/FastBATLLNN/container_results/FastBATLLNN_server_log.out"
echo ".................... Finished Initializing Instance [${ONNXFILE} + ${VNNLIBFILE}]" > "${SCRIPT_DIR}/FastBATLLNN/container_results/FastBATLLNN_server_log.out"