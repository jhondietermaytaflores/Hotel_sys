variable "tenancy_id" {
  type = string
}

variable "compartment_id" {
  type = string
}

variable "region" {
  type = string
}

variable "label_prefix" {
  type = string
}

variable "user_id" {
  type = string
}

variable "api_fingerprint" {
  type = string
}

variable "api_private_key" {
  type     = string
  sensitive = true
}

variable "ssh_public_key_path" {
  type = string
}

variable "ssh_private_key_path" {
  type = string
}
