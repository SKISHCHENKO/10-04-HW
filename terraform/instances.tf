# Образ Ubuntu LTS
data "yandex_compute_image" "ubuntu_2204" {
  family = "ubuntu-2204-lts"
}

# Бастион с публичным IP (в нашей подсети A)
resource "yandex_compute_instance" "bastion" {
  name        = "bastion"
  hostname    = "bastion"
  platform_id = var.vm_platform_id
  zone        = "ru-central1-a"

  resources {
    cores         = 2
    memory        = 1
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu_2204.id
      size     = 10
      type     = "network-hdd"
    }
  }

  scheduling_policy {
    preemptible = true
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.develop_a.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.sg_bastion.id]
  }

  metadata = {
    user-data          = file("${path.module}/cloud-config.yml")
    serial-port-enable = 1
  }
}

# ДВЕ идентичные web-ВМ через count
resource "yandex_compute_instance" "web" {
  count       = 2
  name        = "web-${count.index}"
  hostname    = "web-${count.index}"
  platform_id = var.vm_platform_id
  zone        = var.zone   # ru-central1-a по умолчанию

  resources {
    cores         = 2
    memory        = 1
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu_2204.id
      size     = 10
      type     = "network-hdd"
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.develop_a.id
    nat                = false
    security_group_ids = [yandex_vpc_security_group.sg_web.id]
  }

  metadata = {
    # доступ по SSH через bastion
    "ssh-keys" = local.ssh_meta

    # установка и запуск nginx через cloud-init
    "user-data" = <<EOF
#cloud-config
packages:
  - nginx
runcmd:
  - systemctl enable nginx
  - systemctl start nginx
EOF
  }
}
