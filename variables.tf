variable "do_token" {
  type = string
}

variable "do_region" {
  type = string
}

variable "do_size" {
  type = string
}

variable "do_my_ssh" {
  type = string
}

variable "do_user" {
  type = string
}

variable "email" {
  type = string
}

variable "task" {
  type = string
}

variable "module" {
  type = string
}

variable "aws_zone" {
  type = string
}

variable "aws_access_key" {
  type = string
}

variable "aws_secret_key" {
  type = string
}

variable "aws_name" {
  type = string
}

variable "do_login" {
  type = string
}

variable "conn_type" {
  type = string
}

variable "conn_user" {
  type = string
}

variable "priv_rsa_path" {
  type = string
}

variable "temp_file_path" {
  type = string
}

variable "output_file_path" {
  type = string
}


variable "ans_temp_file_path" {
  type = string
}

variable "invent_file_path" {
  type    = string
  default = "inventory.yml"
}

variable "devs" {
  type = map(string)
}
