#!/bin/bash
# Delete everything that was created: image templates, COS instance, Key Protect instance, VSI instances

source $(dirname "$0")/local.env
source $(dirname "$0")/generated.env
source $(dirname "$0")/scripts/common.sh

# delete the encrypted vsi image
VSI_IMAGE_ID=$(ibmcloud sl image list --private | grep " $IMAGE_ENCRYPTED " | awk '{print $1}')
if ! [ -z "$VSI_IMAGE_ID" ]; then 
  ibmcloud sl image delete $VSI_IMAGE_ID
fi

# delete vsi image and encrypted vsi image
VSI_ID=$(cd tf-vsi-onprem && terraform output VSI_ID)
VSI_IMAGE_ID=$(ibmcloud sl image list --private | grep " ${PREFIX}-${VSI_ID}-image " | awk '{print $1}')
if ! [ -z "$VSI_IMAGE_ID" ]; then 
  ibmcloud sl image delete $VSI_IMAGE_ID
fi

COS_INSTANCE_ID=$(get_instance_id $COS_SERVICE_NAME)
if ! [ -z "$COS_INSTANCE_ID" ]; then 
  ibmcloud resource service-instance-delete $COS_INSTANCE_ID --force --recursive
fi

KP_GUID=$(get_guid $KP_SERVICE_NAME)
KP_KEY_ID=$(get_kp_key_id $KP_GUID $KP_KEY_NAME)
if ! [ -z "$KP_KEY_ID" ]; then 
  if ! [ -z "$KP_GUID" ]; then 
    ibmcloud kp delete $KP_KEY_ID --instance-id $KP_GUID
  fi
fi

KP_INSTANCE_ID=$(get_instance_id $KP_SERVICE_NAME)
if ! [ -z "$KP_INSTANCE_ID" ]; then 
  ibmcloud resource service-instance-delete $KP_INSTANCE_ID --force --recursive
fi

# authorization policy is deleted as part of the KP service deletion, no need to specifically delete

# delete classic vm and vpc vsi
export IC_TIMEOUT=900
export TF_VAR_softlayer_username=$SOFTLAYER_USERNAME
export TF_VAR_softlayer_api_key=$SOFTLAYER_API_KEY
export TF_VAR_region=$REGION
export TF_VAR_ssh_key_label=$SSH_KEY_LABEL
export TF_VAR_ssh_public_key_file=$SSH_PUBLIC_KEY
export TF_VAR_ssh_private_key_file=$SSH_PRIVATE_KEY
export TF_VAR_classic_datacenter=$DATACENTER
export TF_VAR_prefix=$PREFIX

export TF_VAR_ssh_key_name=$VPC_SSH_KEY_NAME
export TF_VAR_resource_group_name=$RESOURCE_GROUP_NAME
export TF_VAR_image_id='12345678'

(cd tf-vsi-test && terraform destroy --auto-approve)
(cd tf-vsi-encrypter && terraform destroy --auto-approve)
(cd tf-vsi-onprem && terraform destroy --auto-approve)
