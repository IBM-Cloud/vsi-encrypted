#!/bin/bash
# Create the ssh key in the cloud.  This will be used by all of the VSIs created.
set -e
set -o pipefail
source $(dirname "$0")/local.env

export IC_TIMEOUT=900
export TF_VAR_softlayer_username=$SOFTLAYER_USERNAME
export TF_VAR_softlayer_api_key=$SOFTLAYER_API_KEY
export TF_VAR_region=$REGION
export TF_VAR_ssh_key_label=$SSH_KEY_LABEL
export TF_VAR_ssh_public_key_file=$SSH_PUBLIC_KEY

# cleanup previous run
# (cd tf-sshkey && rm -rf .terraform terraform.tfstate terraform.tfstate.backup)

# create VSI
(cd tf-sshkey && terraform init && terraform apply --auto-approve)
