#!/bin/bash
# Create a Key Protect service instance, a root key, and the authorization for vsi block storage to access the instance
set -e
set -o pipefail

source $(dirname "$0")/local.env
source $(dirname "$0")/scripts/common.sh

if ibmcloud resource service-instance $KP_SERVICE_NAME >/dev/null 2>&1; then
  echo "Key Protect service $KP_SERVICE_NAME already exists"
else
  echo "Creating Key Protect Service..."
  ibmcloud resource service-instance-create -g $RESOURCE_GROUP_NAME $KP_SERVICE_NAME \
    kms "$KP_SERVICE_PLAN" $KP_REGION || exit 1
fi

KP_GUID=$(get_guid $KP_SERVICE_NAME)
check_value "$KP_GUID"

# Create the root key if needed
if KP_KEY_ID=$(get_kp_key_id $KP_GUID $KP_KEY_NAME); then
  echo "root key $KP_KEY_NAME $KP_KEY_ID already exists"
else
  echo "Creating key protect root key $KP_KEY_NAME"
  ibmcloud kp create $KP_KEY_NAME --instance-id $KP_GUID --output json
  KP_KEY_ID=$(get_kp_key_id $KP_GUID $KP_KEY_NAME)
fi

# Create a policy to make cloud block storage access the Key Protect instance
# cloud block storage is server-protect
if policy=$(get_cloud_block_storage_to_kms_guid_authorization $KP_GUID); then
  echo "Reader policy for cloud block storage to access KP already exists:"
  ibmcloud iam authorization-policy $policy
else
  ibmcloud iam authorization-policy-create \
    server-protect \
    kms \
    Reader \
    --target-service-instance-id $KP_GUID
fi
