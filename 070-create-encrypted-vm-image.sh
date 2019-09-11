#!/bin/bash
set -e
set -o pipefail

source ./local.env
source generated.env

# copy the result back up
# uri is not correct below, the key name exactly as in the COS bucket is required
# The classic image id is not passed
KP_GUID=$(get_guid $KP_SERVICE_NAME)
KP_KEY_ID=$(get_kp_key_id $KP_GUID $KP_KEY_NAME)
KP_CRN=$(ibmcloud kp get $KP_KEY_ID -i $KP_GUID --output json | jq -r '.crn'
DEK_BASE64=$(base64 < dek)
WRAPPED_DEK_BASE64=$(ibmcloud kp wrap $KP_KEY_ID -i $KP_GUID --plaintext $DEK_BASE64 --output json | jq -r '.Ciphertext')

echo ibmcloud sl call-api SoftLayer_Virtual_Guest_Block_Device_Template_Group createFromIcos \
  --parameters '[{"bootMode":"HVM", "operatingSystemReferenceCode":"CENTOS_7_64", "cloudInit":true, "isEncrypted": true, "name": "createfromicoshvm", "uri": "cos://'$COS_REGION'/'$COS_BUCKET_NAME'/'$IMAGE_ENCRYPTED'", "ibmApiKey": "'$(get_ibmcloud_api_key)'", "wrappedDek":"'$WRAPPED_DEK_BASE64'", "crkCrn":"'$KP_CRN'"}]'

echo "Waiting for image $CLASSIC_IMAGE_ID to be Active..."
until ibmcloud sl call-api SoftLayer_Virtual_Guest_Block_Device_Template_Group getObject --init ${CLASSIC_IMAGE_ID} --mask children | jq -c --exit-status 'select (.children[0].transactionId == null)' >/dev/null
do 
