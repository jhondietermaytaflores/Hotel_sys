variable "tenancy_id" {
  type        = string
  description = "OCID del tenancy"
}

variable "compartment_id" {
  type        = string
  description = "OCID del compartment donde crear OKE y red"
}

variable "region" {
  type        = string
  description = "Región OCI, ej: sa-santiago-1"
}

variable "home_region" {
  type        = string
  description = "Región home de tu tenancy"
}

variable "ssh_public_key" {
  type        = string
  description = "Clave pública para los nodos oke-key.pub"
}

variable "ssh_private_key" {
  type        = string
  description = "Clave privada para acceso a nodos oke-key"
}

variable "label_prefix" {
  type        = string
  default     = "hotel"
  description = "Prefijo para recursos"
}
