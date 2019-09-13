#!/bin/bash
# Create a VSI template encrypted image from the encrypted VHD image that in cos
set -e
set -o pipefail

source $(dirname "$0")/local.env
source $(dirname "$0")/generated.env
source $(dirname "$0")/scripts/common.sh

# Use the createFromIcos command to create the image template
KP_GUID=$(get_guid $KP_SERVICE_NAME)
KP_KEY_ID=$(get_kp_key_id $KP_GUID $KP_KEY_NAME)
KP_CRN=$(ibmcloud kp get $KP_KEY_ID -i $KP_GUID --output json | jq -r '.crn')
if [ x"$(uname)" = xDarwin ]; then
  DEK_BASE64=$(base64 < dek)
else
  DEK_BASE64=$(base64 -w 0 < dek)
fi
WRAPPED_DEK_BASE64=$(ibmcloud kp wrap $KP_KEY_ID -i $KP_GUID --plaintext $DEK_BASE64 --output json | jq -r '.Ciphertext')

ibmcloud sl call-api SoftLayer_Virtual_Guest_Block_Device_Template_Group createFromIcos \
  --parameters '[{
      "bootMode":"HVM",
      "operatingSystemReferenceCode":"CENTOS_7_64",
      "cloudInit":true,
      "name": "'$IMAGE_ENCRYPTED'",
      "ibmApiKey": "'$IBMCLOUD_API_KEY'",
      "isEncrypted": true,
      "uri": "cos://'$COS_REGION'/'$COS_BUCKET_NAME'/'$IMAGE_ENCRYPTED'",
      "wrappedDek":"'$WRAPPED_DEK_BASE64'",
      "crkCrn":"'$KP_CRN'"
  }]'

VSI_IMAGE_ID=$(ibmcloud sl image list --private | grep "$IMAGE_ENCRYPTED" | awk '{print $1}')
echo "Waiting for image $VSI_IMAGE_ID to be Active..."
until ibmcloud sl call-api SoftLayer_Virtual_Guest_Block_Device_Template_Group getObject --init $VSI_IMAGE_ID --mask children | jq -c --exit-status 'select (.children[0].transactionId == null)' >/dev/null; do 
  echo -n .
  sleep 5
done
