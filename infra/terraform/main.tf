provider "oci" {
  region = var.region
}

# Alias home_region si lo necesitas
provider "oci" {
  alias  = "home"
  region = var.home_region
}

module "oke" {
  source  = "oracle-terraform-modules/oke/oci"
  version = "5.3.3" # verifica la más reciente en el registry

  tenancy_id     = var.tenancy_id
  compartment_id = var.compartment_id

  home_region = var.home_region
  region      = var.region

  label_prefix = var.label_prefix

  ssh_private_key = var.ssh_private_key
  ssh_public_key  = var.ssh_public_key

  # Configuramos un node pool sencillo
  node_pools = {
    np1 = {
      shape            = "VM.Standard.E4.Flex"
      ocpus            = 2
      memory           = 16
      node_pool_size   = 1
      boot_volume_size = 150
    }
  }

  # Puedes ajustar más parámetros: red, CNI, LB, etc.
  providers = {
    oci.home = oci.home
  }
}
