variable "tenancy_id" {
  type        = string
  description = "OCID del tenancy"
}

variable "compartment_id" {
  type        = string
  description = "OCID del compartment donde crear OKE"
}

variable "region" {
  type        = string
  description = "Región OCI, ej: sa-saopaulo-1"
}

variable "home_region" {
  type        = string
  description = "Región home de tu tenancy"
}
# Claves SSH para nodos OKE
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



# Autenticación para OCI (API signing key)
variable "user_id" {
  type        = string
  description = "OCID del usuario que autentica contra OCI"
}

variable "api_fingerprint" {
  type        = string
  description = "Fingerprint de la API signing key"
}


variable "api_private_key" {
  type        = string
  description = "Contenido PEM de la API signing key"
  sensitive   = true
}

# Rutas donde Terraform encontrará las claves SSH (las crea el workflow)
variable "ssh_public_key_path" {
  type        = string
  description = "Ruta al archivo de clave pública SSH para nodos OKE"
}

variable "ssh_private_key_path" {
  type        = string
  description = "Ruta al archivo de clave privada SSH para nodos OKE"
}
