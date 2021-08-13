#!/bin/bash

. $(dirname "$0")/common.sh

response_file=$(mktemp)
function_name="${2}"
invocations="${1:-100}"
payload="{}"

trap 'rm -f "${response_file}"' EXIT

echo "Function: ${function_name}"
echo "Invocations: ${invocations}"
echo "Payload: ${payload}"

for i in $(seq ${invocations}); do
  aws lambda invoke \
  --function-name "${function_name}" \
  --payload "${payload}" \
  ${response_file} > /dev/null ||
    _panic "Can't invoke the ${function_name} function"

  echo -n "."
done

echo
echo "Done"
