variable "location" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "tags" {
  type = map(string)

  default = {
    "terraform_managed" = "yes"
  }
}

variable "frontend_name" {
  type = string
}
variable "lb_name" {
  type = string
}

variable "sql_admin" {
  type = string
}

variable "sql_password" {
  type = string
}

variable "sql_server_name" {
  type = string
}

variable "sql_server_db" {
  type = string
}

variable "instance_name_prefix" {
  type = string
}