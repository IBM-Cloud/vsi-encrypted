provider "ibm" {
  softlayer_username = "${var.softlayer_username}"
  softlayer_api_key  = "${var.softlayer_api_key}"
  region             = "${var.region}"
}

# use the same key created when capturing the original image
data "ibm_compute_ssh_key" "key" {
  label      = "${var.ssh_key_label}"
}

resource "ibm_compute_vm_instance" "vm" {
  hostname          = "${var.prefix}-encrypter-vm"
  domain            = "howto.cloud"
  ssh_key_ids       = ["${data.ibm_compute_ssh_key.key.id}"]
  os_reference_code = "CENTOS_7_64"
  datacenter        = "${var.classic_datacenter}"
  cores             = 1
  memory            = 2048

/*
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "root"
      private_key = "${file("${var.ssh_private_key_file}")}"
      agent       = false
    }

    # install nginx on the server
    inline = [
      "yum install -y epel-release",
    ]
  }
*/
}

output "VSI_ID" {
  value = "${ibm_compute_vm_instance.vm.id}"
}

output "VSI_IP_ADDRESS" {
  value = "${ibm_compute_vm_instance.vm.ipv4_address}"
}
