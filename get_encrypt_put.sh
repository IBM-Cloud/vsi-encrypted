#!/bin/bash
# Run on the encrypter vsi.  Download the on premises VHD image from COS, encrypt it, put the encrypted image back into COS
set -e
set -o pipefail

source local.env
source generated.env

# install vhd-util
vhd=vhd-util-standalone-3.5.0-xs.2+1.0_71.2.2.x86_64.rpm 
curl -O http://downloads.service.softlayer.com/citrix/xen/$vhd
rpm -iv $vhd

# install ibmcloud cli
curl -fsSL https://clis.cloud.ibm.com/install/linux | sh
ibmcloud plugin install cloud-object-storage

ibmcloud login -r $REGION --apikey $IBMCLOUD_API_KEY
ibmcloud target -g $RESOURCE_GROUP_NAME
ibmcloud target -r $REGION

# download the vhd image
IBMCLOUD_TRACE=false ibmcloud cos download --bucket "$COS_BUCKET_NAME" --key $IMAGE --region $COS_REGION $IMAGE

# encrypt
vhd-util copy -n $IMAGE -N $IMAGE_ENCRYPTED -k dek

# copy up to COS
IBMCLOUD_TRACE=false ibmcloud cos upload --bucket "$COS_BUCKET_NAME" --key $IMAGE_ENCRYPTED --region $COS_REGION -file $IMAGE_ENCRYPTED
