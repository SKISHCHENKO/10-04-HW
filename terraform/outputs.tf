output "bastion_public_ip" {
  description = "Публичный IP бастион-сервера"
  value       = yandex_compute_instance.bastion.network_interface[0].nat_ip_address
}

output "web_private_ips" {
  description = "Приватные IP веб-серверов"
  value = [
    for inst in yandex_compute_instance.web :
    inst.network_interface[0].ip_address
  ]
}

output "subnets" {
  description = "CIDR созданных подсетей"
  value = {
    develop_a = yandex_vpc_subnet.develop_a.v4_cidr_blocks[0]
    develop_b = yandex_vpc_subnet.develop_b.v4_cidr_blocks[0]
  }
}

output "nlb_public_ip" {
  description = "Публичный IP сетевого балансировщика"
  value       = yandex_lb_network_load_balancer.web_nlb.listener[0].address
}
