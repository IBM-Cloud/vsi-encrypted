#!/bin/bash
set -e

./000-initialize-verify-prereqs.sh
./010-prepare-cos.sh
./015-create-sshkey-in-cloud.sh
./020-create-onprem-vm.sh
./030-capture-classic-to-cos.sh
./040-create-encrypter-vm.sh
./050-use-vsi-encrypter-to-encrypt-cos-image.sh
./060-prepare-kp.sh
./070-create-encrypted-vm-image-template.sh
./080-create-test-vm.sh
./090-cleanup.sh
