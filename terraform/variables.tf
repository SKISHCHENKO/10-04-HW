variable "cloud_id" {
  description = "Yandex Cloud ID"
  type        = string
  default     = "b1ghf5g8o4mhdlrvofo5"
}

variable "folder_id" {
  description = "Yandex Cloud Folder ID"
  type        = string
  default     = "b1gcaq8clab0al7c1qhs"
}

variable "zone" {
  description = "Default zone"
  type        = string
  default     = "ru-central1-a"
}

variable "develop_cidr_a" {
  description = "CIDR приватной подсети"
  type        = string
  default     = "10.10.1.0/24"
}

variable "develop_cidr_b" {
  description = "CIDR приватной подсети"
  type        = string
  default     = "10.10.2.0/24"
}

variable "ssh_public_key" {
  description = "Содержимое public-ключа (строка из ~/.ssh/id_ed25519.pub)"
  type        = string
  sensitive   = true
}

variable "instance_user" {
  description = "Пользователь ОС в образе (ubuntu для Ubuntu)"
  type        = string
  default     = "ubuntu"
}

variable "vm_platform_id" {
  description = "Платформа ВМ"
  type        = string
  default     = "standard-v3"
}
