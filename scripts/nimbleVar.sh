#!/bin/bash
#
# This generates a list of variables you can source which map to variables in a .nimble file
# Everything is prefixed with `nimble_`
set -e
set -o pipefail
# Let the first run of nimble happen. This removes any prompts since logging goes over stdout
# https://github.com/nim-lang/nimble/issues/1339
nimble dump > /dev/null
# Now try to parse the JSON
nimble dump --json | jq -r 'to_entries[] | select(.value | type == "string") | "export nimble_\(.key)=\(.value | @sh)"'
