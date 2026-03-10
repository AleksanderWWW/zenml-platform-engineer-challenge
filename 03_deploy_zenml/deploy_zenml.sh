#!/bin/bash

ROLE_NAME="zenml-server-role"

ZENML_ROLE_ARN=$(aws iam get-role --role-name "$ROLE_NAME" --query 'Role.Arn' --output text)

# Verify we actually got something
if [ -z "$ZENML_ROLE_ARN" ]; then
  echo "Error: Could not find IAM Role $ROLE_NAME"
  exit 1
fi


helm upgrade -i zenml -n zenml <...> --values values.yaml \
    --set serviceAccount.annotations."eks\.amazonaws\.com/role-arn"="${ZENML_ROLE_ARN}"
