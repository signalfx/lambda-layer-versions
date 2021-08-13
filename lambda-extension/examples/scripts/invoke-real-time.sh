#!/bin/bash

. $(dirname "$0")/common.sh

$(dirname "$0")/invoke-function.sh ${1} ${REAL_TIME_FUNCTION_NAME}
