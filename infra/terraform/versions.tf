terraform {
  required_version = ">= 1.5.0"

  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 4.67.0"
    }
  }

  # Más adelante puedes cambiar a backend remoto en Object Storage
  backend "local" {}
}
