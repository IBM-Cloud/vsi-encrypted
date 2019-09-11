#!/bin/bash

source ./local.env
source ./generated.env

# include common functions
source $(dirname "$0")/scripts/common.sh

export TF_VAR_image_id=TODO

# delete vsi image and encrypted vsi image
VSI_ID=$(cd vsi-onprem && terraform output VSI_ID)
VSI_IMAGE_ID=$(ibmcloud sl image list --private | grep "${PREFIX}-${VSI_ID}-image" | awk '{print $1}')
ibmcloud sl image delete $VSI_IMAGE_ID

# TODO delete encrypted image

if false; then #-----------------------------
COS_INSTANCE_ID=$(get_instance_id $COS_SERVICE_NAME)
COS_GUID=$(get_guid $COS_SERVICE_NAME)
ibmcloud resource service-instance-delete $COS_INSTANCE_ID --force --recursive
fi; #--------------------------------------------

KP_GUID=$(get_guid $KP_SERVICE_NAME)
KP_KEY_ID=$(get_kp_key_id $KP_GUID $KP_KEY_NAME)
ibmcloud kp delete $KP_KEY_ID --instance-id $KP_GUID
KP_INSTANCE_ID=$(get_instance_id $KP_SERVICE_NAME)
ibmcloud resource service-instance-delete $KP_INSTANCE_ID --force --recursive
exit 0; #-----------------------------------------

if policy=$(get_cloud_block_storage_to_kms_guid_authorization $KP_GUID); then
  ibmcloud iam authorization-policy-delete $policy
fi

# delete classic vm and vpc vsi
export IC_TIMEOUT=900
export TF_VAR_softlayer_username=$SOFTLAYER_USERNAME
export TF_VAR_softlayer_api_key=$SOFTLAYER_API_KEY
export TF_VAR_region=$REGION
export TF_VAR_ssh_public_key_file=$SSH_PUBLIC_KEY
export TF_VAR_ssh_private_key_file=$SSH_PRIVATE_KEY
export TF_VAR_classic_datacenter=$DATACENTER
export TF_VAR_prefix=$PREFIX

export TF_VAR_ssh_key_name=$VPC_SSH_KEY_NAME
export TF_VAR_resource_group_name=$RESOURCE_GROUP_NAME
export TF_VAR_vsi_image_name=$(echo $PREFIX-$CLASSIC_ID-image | tr '[:upper:]' '[:lower:]')

(cd vsi-test && terraform destroy --auto-approve)
(cd vsi-encrypter && terraform destroy --auto-approve)
(cd vsi-onprem && terraform destroy --auto-approve)
ibmcloud iam api-key-delete $APIKEY -f
rm apikey.json
