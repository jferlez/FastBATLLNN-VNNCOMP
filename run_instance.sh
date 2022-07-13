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

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )