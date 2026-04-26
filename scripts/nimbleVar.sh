#!/bin/bash
#
# This generates a list of variables you can source which map to variables in a .nimble file
# Everything is prefixed with `nimble_`
set -e
set -o pipefail

nimble dump --json | tee >(cat 1>&2) | jq -r 'to_entries[] | select(.value | type == "string") | "export nimble_\(.key)=\(.value | @sh)"'
