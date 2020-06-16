# Automate the Encryption of a Virtual Server Image for Deployment onto Classic Infrastructure

## Overview

You can [Use End to End (E2E) Encryption to provision an encrypted instance](https://cloud.ibm.com/docs/infrastructure/image-templates?topic=image-templates-using-end-to-end-e2e-encryption-to-provision-an-encrypted-instance).  Start with an on premises file in Virtual Hardware Device, VHD format.  Encrypt the VHD on premises and end up with a Virtual Server Instance in the IBM cloud running directly from that encrypted VHD file.

## Create a VSI template image that is encrypted

> The scripts do not check permissions. You must ensure you have the right permissions:
> - to create Classic virtual server instances with public network,
> - to capture Classic instance images,
> - to create Cloud Object Storage instance,
> - to create Key Protect instance,

1. Copy the configuration file and set the values to match your environment.

   ```sh
   cp template.local.env local.env
   ```

1. Initialize and verify prerequisites - Set the default resource group and region verify prerequisites

   ```sh
   ./000-initialize-verify-prereqs.sh
   ``

1. Create a Cloud Object Storage, COS, instance and create an initial bucket

   ```sh
   ./010-prepare-cos.sh
   ```

1. Create the ssh key in the cloud.  This will be used by all of the VSIs created.

   ```sh
   ./015-create-sshkey-in-cloud.sh
   ```

1. Create the VSI representing the on premises instance.  The VHD will be created from this instance

   ```sh
   ./020-create-onprem-vm.sh
   ```
   > The script installs Nginx on this instance. It will test that the virtual server instance is accessible through its public address and retrieve the Nginx home page.

1. Create a VHD image template of the on premises VSI.  Copy the image into a COS bucket.

   ```sh
   ./030-capture-classic-to-cos.sh
   ```

1. Create a VSI used to encrypt the VHD image.

   ```sh
   ./040-create-encrypter-vm.sh
   ```

1. Encrypt the VHD image that is in COS: copy the VHD locally, encrypt with the data encryption key, copy encrypted VHD back to COS.  Do this on a VSI.
   ```sh
   ./050-use-vsi-encrypter-to-encrypt-cos-image.sh
   ```
   > Create a data encryption key in the file dek if the dek file does not exist.

1. Create a Key Protect service instance, a root key, and the authorization for vsi block storage to access the instance
   ```sh
   ./060-prepare-kp.sh
   ```

1. Create a VSI template encrypted image from the encrypted VHD image that in cos
   ```sh
   ./070-create-encrypted-vm-image-template.sh
   ```

1. Create a VSI from the encrypted template image
   ```sh
   ./080-create-test-vm.sh
   ```

   > The script will test that the virtual server instance is accessible through its public address and retrieve the Nginx home page to confirm the migration worked as expected.

## Cleanup

Delete everything that was created: image templates, COS instance, Key Protect instance, VSI instances

   ```sh
   ./090-cleanup.sh
   ```
