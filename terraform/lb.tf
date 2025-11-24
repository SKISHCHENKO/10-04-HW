#############################################
# Target group для двух web-ВМ
#############################################
resource "yandex_lb_target_group" "web_tg" {
  name = "tg-web"

  dynamic "target" {
    for_each = yandex_compute_instance.web
    content {
      subnet_id = yandex_vpc_subnet.develop_a.id
      address   = target.value.network_interface[0].ip_address
    }
  }
}

#############################################
# Network Load Balancer (внешний)
#############################################
resource "yandex_lb_network_load_balancer" "web_nlb" {
  name = "nlb-web"
  type = "external"

  # слушаем порт 80 извне, прокидываем на порт 80 ВМ
  listener {
    name        = "http"
    port        = 80
    target_port = 80
    protocol    = "tcp"
  }

  attached_target_group {
    target_group_id = yandex_lb_target_group.web_tg.id

    healthcheck {
      name                = "http"
      interval            = 3
      timeout             = 2
      unhealthy_threshold = 2
      healthy_threshold   = 2

      http_options {
        port = 80
        path = "/"
      }
    }
  }
}
