#!/bin/bash
# Create a VHD image template of the on premises VSI.  Copy the image into a COS bucket.
set -e
set -o pipefail

source $(dirname "$0")/scripts/common.sh
source $(dirname "$0")/local.env

# capture image
VSI_ID=$(cd tf-vsi-onprem && terraform output VSI_ID)

echo "Capturing image for the on premises VSI $VSI_ID..."
ibmcloud sl vs capture $VSI_ID -n ${PREFIX}-${VSI_ID}-image --note "capture of ${VSI_ID}"

# wait for the image to be Active
VSI_IMAGE_ID=$(ibmcloud sl image list --private | grep "${PREFIX}-${VSI_ID}-image" | awk '{print $1}')
echo "Waiting for image $VSI_IMAGE_ID to be Active..."
until ibmcloud sl call-api SoftLayer_Virtual_Guest_Block_Device_Template_Group getObject --init ${VSI_IMAGE_ID} --mask children | jq -c --exit-status 'select (.children[0].transactionId == null)' >/dev/null
do 
    echo -n "."
    sleep 10
done
echo ""

# copy image to COS
echo "Copying image to COS..."
ibmcloud sl call-api SoftLayer_Virtual_Guest_Block_Device_Template_Group copyToIcos \
  --init ${VSI_IMAGE_ID} --parameters '[{
    "uri": "cos://'$COS_REGION'/'$COS_BUCKET_NAME'/'$PREFIX'-'$VSI_ID'-image.vhd",
    "ibmApiKey": "'$IBMCLOUD_API_KEY'"
  }]'

cos_image="$PREFIX-$VSI_ID-image-0.vhd"
echo "Waiting for the $cos_image to be ready in COS..."
until ibmcloud cos head-object --bucket "$COS_BUCKET_NAME" --key "$cos_image" --region $COS_REGION > /dev/null 2>&1
do 
    echo -n "."
    sleep 10
done
echo ""
echo "IMAGE=$cos_image" >> generated.env

# The encrypter is going to put an encrypted version of the image into this object in the COS bucket
echo "IMAGE_ENCRYPTED=$PREFIX-$VSI_ID-image-encrypted-0.vhd" >> generated.env

echo "Image $cos_image copied to bucket "$COS_BUCKET_NAME" check out file generated.env"
