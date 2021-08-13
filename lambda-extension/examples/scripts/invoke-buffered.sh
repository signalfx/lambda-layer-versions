#!/bin/bash

. $(dirname "$0")/common.sh

$(dirname "$0")/invoke-function.sh ${1} ${BUFFERED_FUNCTION_NAME}
