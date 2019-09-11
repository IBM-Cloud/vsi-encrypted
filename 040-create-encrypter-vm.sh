#!/bin/bash
# create a vsi for encrypting the on premise VHD image.  Wrapper around terraform
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

# cleanup previous run
# (cd vsi-encrypter && rm -rf .terraform terraform.tfstate terraform.tfstate.backup)

# create VSI
(cd vsi-encrypter && terraform init && terraform apply --auto-approve)
