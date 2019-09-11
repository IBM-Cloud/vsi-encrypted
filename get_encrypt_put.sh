#!/bin/bash
set -e
set -o pipefail

source local.env

# install vhd-util
vhd=vhd-util-standalone-3.5.0-xs.2+1.0_71.2.2.x86_64.rpm 
curl -O http://downloads.service.softlayer.com/citrix/xen/$vhd
rpm -iv $vhd

# This is the hard coded copy that was provided
# rpm -iv vhd-util-standalone-3.5.0-xs.2+1.0_71.2.4.x86_64.rpm

# install ibmcloud cli
curl -fsSL https://clis.cloud.ibm.com/install/linux | sh
ibmcloud plugin install cloud-object-storage

ibmcloud login -r $REGION --apikey @./apikey.json

# download the vhd image
CLASSIC_ID=$(cat CLASSIC_ID)
cos_image="$PREFIX-$CLASSIC_ID-image-0.vhd"
IBMCLOUD_TRACE=false ibmcloud cos get-object --bucket "$COS_BUCKET_NAME" --key $cos_image --region $COS_REGION $cos_image

# encrypt
encrypted_image="$PREFIX-$CLASSIC_ID-image-encrypted-0.vhd"
vhd-util copy -n $cos_image -N $encrypted_image -k dek

# copy up to COS
IBMCLOUD_TRACE=false ibmcloud cos put-object --bucket "$COS_BUCKET_NAME" --key $encrypted_image --region $COS_REGION $encrypted_image

# If aws cli is required
if false; then
  sudo yum install centos-release-scl -y
  sudo yum install rh-python36 -y
  scl enable rh-python36 bash
  source local.env
  pip3 install awscli --upgrade
  ibmcloud resource service-key-create $PREFIX Writer --instance-name "$COS_SERVICE_NAME" --parameters '{"HMAC":true}' > cos.skey
  aws configure
    us-south-standard
  aws s3 --endpoint-url https://s3.us-south.cloud-object-storage.appdomain.cloud  ls
  aws s3 --endpoint-url https://s3.us-south.cloud-object-storage.appdomain.cloud  cp  s3://pfq00-e2e-classic-images/pfq00-e2e-89241324-image-0.vhd pfq00-e2e-89241324-image-0.vhd
  aws s3 --endpoint-url https://s3.us-south.cloud-object-storage.appdomain.cloud  cp  pfq00-e2e-89241324-image-0.vhd s3://pfq00-e2e-classic-images/pfq00-e2e-89241324-image-copy-0.vhd
fi
