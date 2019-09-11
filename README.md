# Migrate a Classic infrastructure instance to a VPC infrastructure instance

## Overview

You can encrpt an existing *Classic* virtual server instance and provision a new virtual server instance with this encrptyed imaage [Using End to End (E2E) Encryption to provision an encrypted instan](https://cloud.ibm.com/docs/infrastructure/image-templates?topic=image-templates-using-end-to-end-e2e-encryption-to-provision-an-encrypted-instance)

The steps are:

1. Create a Cloud Object Storage instance and a bucket to store the captured image.

## Capture a Classic VSI to VPC VSI

> The scripts do not check permissions. You must ensure you have the right permissions:
> - to create Classic virtual server instances with public network,
> - to capture Classic instance images,
> - to create Cloud Object Storage instance,
> - to create VPC, subnets, servers

NOTE the step that creates the encrypted image on the working VSI instance creates an api key.  If the script completes correctly the api key will be deleted, but if the script fails you should delete it.

1. Copy the configuration file and set the values to match your environment.

   ```sh
   cp template.local.env local.env
   ```

1. Load the values into the current shell.

   ```sh
   source local.env
   ```

1. Ensure you have the prerequisites to run the scripts.

   ```sh
   ./000-prereqs.sh
   ```

1. Create a Cloud Object Storage instance to capture the Classic instance image

   ```sh
   ./010-prepare-cos.sh
   ```

1. Create a Classic virtual server instance.

   ```sh
   ./020-create-classic-vm.sh
   ```

   > The script installs Nginx on this instance. It will test that the virtual server instance is accessible through its public address and retrieve the Nginx home page.

1. Capture an image of the Classic virtual server instance.

   ```sh
   ./030-capture-classic-to-cos.sh
   ```

1. Import the captured image into VPC.

   ```sh
   ./040-import-image-to-vpc.sh
   ```

1. Create a VPC and a virtual server instance from the image.

   ```sh
   ./050-provision-vpc-vsi.sh
   ```

   > The script will test that the virtual server instance is accessible through its public address and retrieve the Nginx home page to confirm the migration worked as expected.

## Cleanup

To delete the *Classic* VSI, the Cloud Object Storage instance, the images, the VPC, run:

   ```sh
   ./060-cleanup.sh
   ```

-------------------
ibm_compute_ssh_key.key - figure out what to do with this
export TF_VAR_ibmcloud_api_key=$IBMCLOUD_API_KEY

1. Capture an image of a classic VSI.
1. Export the image to Cloud Object Storage.
1. Import this image into VPC custom image list.
1. Provision a VSI from this image.

The scripts in this folder show an example to migrate a CentOS VSI running in the Classic Infrastructure to a VSI running in VPC on Classic. The scripts automate all steps you would find while going through the documentation:
1. Create a Cloud Object Storage instance and a bucket to store the captured image.
1. Set up an authorization between Cloud Object Storage and the VPC Image service.
1. Create a VSI in the Classic Infrastructure.
1. Install Nginx on the VSI so that later we can verify the new VSI also runs Nginx.
1. Capture the VSI image and wait for the image to be ready.
1. Copy the image to Cloud Object Storage.
1. Import the image into the VPC Custom Image list once the image is ready in Cloud Object Storage.
1. Provision a new VSI in VPC on Classic from this image.

