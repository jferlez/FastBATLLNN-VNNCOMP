#!/bin/bash

# Takes six arguments in this order:
#   "v1";
#   benchmark identifier string such as "acasxu";
#   path to the .onnx file;
#   path to .vnnlib file;
#   path to the results file;
#   timeout in seconds.
# 
# Your script will be killed if it exceeds the timeone by too much, but sometimes gracefully quitting is better if 
# you want to release resources cleanly like GPUs. The results file should be created after the script is run and 
# is a simple text file containing one word on a single line: holds, violated, timeout, error, or unknown.

WORKING_DIR="$(pwd)"
SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

BENCHMARK=$2
ONNXFILE="$3"
VNNLIBFILE="$4"
RESULTFILE="$5"
TIMEOUT=$6

# Skip anything that isn't a TLL
if [ "$BENCHMARK" != "tllverifybench" ]; then
    exit 1
fi

export PYTHONPATH="${SCRIPT_DIR}/FastBATLLNN:${SCRIPT_DIR}/FastBATLLNN/HyperplaneRegionEnum:${SCRIPT_DIR}/FastBATLLNN/TLLnet:${SCRIPT_DIR}/nnenum/src/nnenum"

python3 -m FastBATLLNNClient getResult "$ONNXFILE" "$VNNLIBFILE" $TIMEOUT > "$RESULTFILE"

# make sure server logs get printed to stdout on the host
cat "${SCRIPT_DIR}/FastBATLLNN/container_results/FastBATLLNN_server_log.out"
echo ".................... Obtained Results for Instance [${ONNXFILE} + ${VNNLIBFILE}]" > "${SCRIPT_DIR}/FastBATLLNN/container_results/FastBATLLNN_server_log.out"

# For now, only shutdown the server after the last network
if [ "`basename \"$ONNXFILE\"`" = "tllBench_n=2_N=M=64_m=1_instance_7_3.onnx" ]; then
    python3 -m FastBATLLNNClient shutdown
fi
# Alternately, shutdown the server after every network; prepare_instance.sh will automatically restart it anyway
# python3 -m FastBATLLNNClient shutdown