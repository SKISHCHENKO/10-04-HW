#############################################
# Используем существующую VPC-сеть "default"
#############################################
data "yandex_vpc_network" "default" {
  name = "default"
}

#############################################
# NAT Gateway + Route Table в сети default
#############################################
resource "yandex_vpc_gateway" "nat" {
  name = "nat-default"
  shared_egress_gateway {}
}

resource "yandex_vpc_route_table" "rt" {
  name       = "rt-default-web"
  network_id = data.yandex_vpc_network.default.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.nat.id
  }
}

#######################################################
# ДВЕ НОВЫЕ подсети в сети default (НЕ default-*)
# CIDR не должны пересекаться с 10.128.0.0/24 и 10.129.0.0/24
#######################################################
resource "yandex_vpc_subnet" "develop_a" {
  name           = "develop-a"
  zone           = "ru-central1-a"
  network_id     = data.yandex_vpc_network.default.id
  v4_cidr_blocks = [var.develop_cidr_a]   # напр. 10.10.1.0/24
  route_table_id = yandex_vpc_route_table.rt.id
}

resource "yandex_vpc_subnet" "develop_b" {
  name           = "develop-b"
  zone           = "ru-central1-b"
  network_id     = data.yandex_vpc_network.default.id
  v4_cidr_blocks = [var.develop_cidr_b]   # напр. 10.10.2.0/24
  route_table_id = yandex_vpc_route_table.rt.id
}

#############################################
# Security Groups в сети default
#############################################
# 1) Бастион: SSH с интернета
resource "yandex_vpc_security_group" "sg_bastion" {
  name        = "sg-bastion"
  description = "Allow SSH from anywhere (demo); restrict in prod."
  network_id  = data.yandex_vpc_network.default.id

  ingress {
    protocol       = "TCP"
    description    = "SSH from any"
    port           = 22
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description    = "Permit ANY"
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

# 2) Web: SSH только с бастиона, HTTP/HTTPS отовсюду
resource "yandex_vpc_security_group" "sg_web" {
  name       = "sg-web"
  network_id = data.yandex_vpc_network.default.id

  # HTTP 80
  ingress {
    protocol       = "TCP"
    port           = 80
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS 443 (на будущее)
  ingress {
    protocol       = "TCP"
    port           = 443
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  # SSH 22 только от ВМ из sg_bastion
  ingress {
    protocol          = "TCP"
    port              = 22
    security_group_id = yandex_vpc_security_group.sg_bastion.id
  }

  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}
