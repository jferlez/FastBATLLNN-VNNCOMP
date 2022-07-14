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
