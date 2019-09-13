provider "ibm" {
  softlayer_username = "${var.softlayer_username}"
  softlayer_api_key  = "${var.softlayer_api_key}"
  region             = "${var.region}"
}

data "ibm_compute_ssh_key" "key" {
  label      = "${var.ssh_key_label}"
}

resource "ibm_compute_vm_instance" "vm" {
  hostname          = "${var.prefix}-test-vm"
  domain            = "howto.cloud"
  ssh_key_ids       = ["${data.ibm_compute_ssh_key.key.id}"]
  image_id          = "${var.image_id}"
  datacenter        = "${var.classic_datacenter}"
  cores             = 1
  memory            = 1024
}

output "VSI_ID" {
  value = "${ibm_compute_vm_instance.vm.id}"
}

output "VSI_IP_ADDRESS" {
  value = "${ibm_compute_vm_instance.vm.ipv4_address}"
}
