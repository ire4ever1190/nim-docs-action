#!/bin/sh
#
# This generates a list of variables you can source which map to variables in a .nimble file
# Everything is prefixed with `nimble_`
set -e
set -o pipefail

nimble dump | sed -E "s/(\w+): \"(.*)\"/nimble_\\1=\\2/" | source
