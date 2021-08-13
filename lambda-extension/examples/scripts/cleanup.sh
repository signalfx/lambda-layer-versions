#!/bin/bash

. $(dirname "$0")/common.sh

if (aws lambda get-function --function-name "${BUFFERED_FUNCTION_NAME}" --no-cli-pager > /dev/null 2> /dev/null); then
  aws lambda delete-function --no-cli-pager \
    --function-name "${BUFFERED_FUNCTION_NAME}" ||
      _panic "Can't delete the ${BUFFERED_FUNCTION_NAME} function"

  echo "The ${BUFFERED_FUNCTION_NAME} function was deleted"
fi

if (aws lambda get-function --function-name "${REAL_TIME_FUNCTION_NAME}" --no-cli-pager > /dev/null 2> /dev/null); then
  aws lambda delete-function --no-cli-pager \
    --function-name "${REAL_TIME_FUNCTION_NAME}" ||
      _panic "Can't delete the ${REAL_TIME_FUNCTION_NAME} function"

  echo "The ${REAL_TIME_FUNCTION_NAME} function was deleted"
fi

aws iam detach-role-policy --no-cli-pager \
  --role-name "${ROLE_NAME}" \
  --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole

aws iam delete-role \
  --role-name "${ROLE_NAME}" \
  --no-cli-pager ||
  _panic "Can't delete the ${ROLE_NAME} role"

echo "The ${ROLE_NAME} role was deleted"
