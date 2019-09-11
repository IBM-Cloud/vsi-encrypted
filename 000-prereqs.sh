#!/bin/bash
set -e

source local.env

echo ">>> Targeting resource group $RESOURCE_GROUP_NAME..."
ibmcloud target -g $RESOURCE_GROUP_NAME

echo ">>> Targeting region $REGION..."
ibmcloud target -r $REGION

echo ">>> Ensuring Cloud Object Storage plugin is installed"
if ibmcloud cos config list >/dev/null; then
  echo "cloud-object-storage plugin is OK"
  # clear any default crn as it could prevent COS calls to work
  ibmcloud cos config crn --crn "" --force
else
  echo '*** must install cloud-object-storage plugin is installed with ibmcloud plugin install cloud-object-storage.'
  exit 1
fi

echo ">>> Ensuring Key Protect plugin is installed"
if ibmcloud kp >/dev/null; then
  echo "key protect, kp, plugin is OK"
else
  echo '*** Must install kp plugin with ibmcloud plugin install kp'
  exit 1
fi

echo ">>> Is terraform installed?"
terraform version

echo ">>> Is jq (https://stedolan.github.io/jq/) installed?"
jq -V

echo ">>> Is curl installed?"
curl -V

echo "#Generated environment variables IMAGE and IMAGE_ENCRYPTED file names" > generated.env

ibmcloud iam api-key-create $APIKEY -d 'e2e scripting generated' --file apikey.json
echo generated apikey.json containing the api key.  See 090-cleanup.sh where this is deleted
