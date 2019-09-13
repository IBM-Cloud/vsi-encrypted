#!/bin/bash
# Create a VSI from the encrypted template image
set -e
set -o pipefail

source $(dirname "$0")/local.env
source $(dirname "$0")/generated.env

export IC_TIMEOUT=900
export TF_VAR_softlayer_username=$SOFTLAYER_USERNAME
export TF_VAR_softlayer_api_key=$SOFTLAYER_API_KEY
export TF_VAR_region=$REGION
export TF_VAR_ssh_key_label=$SSH_KEY_LABEL
export TF_VAR_ssh_public_key_file=$SSH_PUBLIC_KEY
export TF_VAR_ssh_private_key_file=$SSH_PRIVATE_KEY
export TF_VAR_classic_datacenter=$DATACENTER
export TF_VAR_prefix=$PREFIX

VSI_IMAGE_ID=$(ibmcloud sl image list --private | grep "$IMAGE_ENCRYPTED" | awk '{print $1}')
export TF_VAR_image_id=$VSI_IMAGE_ID

# cleanup previous run
# (cd tf-vsi-test && rm -rf .terraform terraform.tfstate terraform.tfstate.backup)

# create VSI
(cd tf-vsi-test && terraform init && terraform apply --auto-approve)

# test it
TEST_IP_ADDRESS=$(cd tf-vsi-onprem && terraform output VSI_IP_ADDRESS)
if curl --connect-timeout 10 http://$TEST_IP_ADDRESS; then
  echo "Encrypted image is running - YEAH"
else
  echo "Can't reach the encrypted public IP address $TEST_IP_ADDRESS - FAIL"
  exit 1
fi
