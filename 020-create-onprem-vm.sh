#!/bin/bash
# Create the VSI representing the on premises instance.  The VHD will be created from this instance
set -e
set -o pipefail
source $(dirname "$0")/local.env

export IC_TIMEOUT=900
export TF_VAR_softlayer_username=$SOFTLAYER_USERNAME
export TF_VAR_softlayer_api_key=$SOFTLAYER_API_KEY
export TF_VAR_region=$REGION
export TF_VAR_ssh_key_label=$SSH_KEY_LABEL
export TF_VAR_ssh_public_key_file=$SSH_PUBLIC_KEY
export TF_VAR_ssh_private_key_file=$SSH_PRIVATE_KEY
export TF_VAR_classic_datacenter=$DATACENTER
export TF_VAR_prefix=$PREFIX

# cleanup previous run
# (cd tf-vsi-onprem && rm -rf .terraform terraform.tfstate terraform.tfstate.backup)

# create VSI
(cd tf-vsi-onprem && terraform init && terraform apply --auto-approve)

ONPREM_IP_ADDRESS=$(cd tf-vsi-onprem && terraform output VSI_IP_ADDRESS)
if curl --connect-timeout 10 http://$ONPREM_IP_ADDRESS; then
  echo "On premises VM is ready to be captured"
else
  echo "Can't reach the on premises VM public IP address: $ONPREM_IP_ADDRESS"
  exit 1
fi
