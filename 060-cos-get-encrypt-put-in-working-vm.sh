#!/bin/bash
set -e
set -o pipefail

source ./local.env

ENCRYPTER_IP_ADDRESS=$(cd vsi-encrypter && terraform output VSI_IP_ADDRESS)
scp -F scripts/ssh.notstrict.config dek local.env generated.env get_encrypt_put.sh apikey.json root@$ENCRYPTER_IP_ADDRESS:
echo ssh -F scripts/ssh.notstrict.config root@$ENCRYPTER_IP_ADDRESS bash -x get_encrypt_put.sh
