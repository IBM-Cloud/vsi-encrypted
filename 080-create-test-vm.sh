#!/bin/bash
set -e
set -o pipefail

source ./local.env

export IC_TIMEOUT=900
export TF_VAR_softlayer_username=$SOFTLAYER_USERNAME
export TF_VAR_softlayer_api_key=$SOFTLAYER_API_KEY
export TF_VAR_region=$REGION
export TF_VAR_ssh_public_key_file=$SSH_PUBLIC_KEY
export TF_VAR_ssh_private_key_file=$SSH_PRIVATE_KEY
export TF_VAR_classic_datacenter=$DATACENTER
export TF_VAR_prefix=$PREFIX

export TF_VAR_image_id=$

# cleanup previous run
# (cd vsi-test && rm -rf .terraform terraform.tfstate terraform.tfstate.backup)

# create VSI
(cd vsi-test && terraform init && terraform apply --auto-approve)
TEST_IP_ADDRESS=$(cd vsi-test && terraform output VSI_IP_ADDRESS)
echo trying to curl $TEST_IP_ADDRESS
curl $TEST_IP_ADDRESS
