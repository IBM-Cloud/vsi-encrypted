#!/bin/bash
# Encrypt the VHD image that is in COS: copy the VHD locally, encrypt with the data encryption key, copy encrypted VHD back to COS.  Do this on a VSI.
set -e
set -o pipefail

source $(dirname "$0")/local.env

if [ -e dek ]; then
  echo using existing dek file
else
  echo generating new dek file
  dd if=/dev/urandom of=dek bs=64 count=1
fi

ENCRYPTER_IP_ADDRESS=$(cd tf-vsi-encrypter && terraform output VSI_IP_ADDRESS)
scp -F scripts/ssh.notstrict.config dek local.env generated.env get_encrypt_put.sh root@$ENCRYPTER_IP_ADDRESS:
ssh -F scripts/ssh.notstrict.config root@$ENCRYPTER_IP_ADDRESS bash -x get_encrypt_put.sh
