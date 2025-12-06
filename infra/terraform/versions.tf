terraform {
  required_version = ">= 1.5.0"

  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 4.67.0"
    }
  }

  # TODO: Cambia esto para usar backend remoto en Object Storage
  # backend "local" {}
}
