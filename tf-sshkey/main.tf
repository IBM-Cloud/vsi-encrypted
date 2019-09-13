provider "ibm" {
  softlayer_username = "${var.softlayer_username}"
  softlayer_api_key  = "${var.softlayer_api_key}"
  region             = "${var.region}"
}

resource "ibm_compute_ssh_key" "key" {
  label      = "${var.ssh_key_label}"
  public_key = "${file("${var.ssh_public_key_file}")}"
}

