#!/bin/bash
# Create a Cloud Object Storage, COS, instance and create an initial bucket
set -e
set -o pipefail

source $(dirname "$0")/local.env
source $(dirname "$0")/generated.env
source $(dirname "$0")/scripts/common.sh

if ibmcloud resource service-instance $COS_SERVICE_NAME >/dev/null 2>&1; then
  echo "Cloud Object Storage service $COS_SERVICE_NAME already exists"
else
  echo "Creating Cloud Object Storage Service..."
  ibmcloud resource service-instance-create -g $RESOURCE_GROUP_NAME $COS_SERVICE_NAME \
    cloud-object-storage "$COS_SERVICE_PLAN" global || exit 1
fi

COS_INSTANCE_ID=$(get_instance_id $COS_SERVICE_NAME)
check_value "$COS_INSTANCE_ID"
COS_GUID=$(get_guid $COS_SERVICE_NAME)
check_value "$COS_GUID"

# Create the bucket
if ibmcloud cos head-bucket --bucket $COS_BUCKET_NAME --region $COS_REGION > /dev/null 2>&1; then
  echo "Bucket $COS_BUCKET_NAME already exists"
else
  echo "Creating storage bucket $COS_BUCKET_NAME"
  ibmcloud cos create-bucket \
    --bucket $COS_BUCKET_NAME \
    --ibm-service-instance-id $COS_INSTANCE_ID \
    --region $COS_REGION
fi
