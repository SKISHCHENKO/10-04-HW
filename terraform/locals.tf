locals {
  # Формат, ожидаемый YC: "<user>:<pubkey>"
  ssh_meta = "${var.instance_user}:${var.ssh_public_key}"
}
