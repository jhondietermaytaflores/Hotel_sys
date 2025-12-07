provider "oci" {
  tenancy_ocid = var.tenancy_id
  user_ocid    = var.user_id
  fingerprint  = var.api_fingerprint
  private_key  = var.api_private_key
  region       = var.region
}

provider "oci" {
  alias        = "home"
  tenancy_ocid = var.tenancy_id
  user_ocid    = var.user_id
  fingerprint  = var.api_fingerprint
  private_key  = var.api_private_key
  region       = var.home_region
}


module "oke" {
  source  = "oracle-terraform-modules/oke/oci"
  version = "7.1.0" # verifica la más reciente en el registry

  tenancy_id     = var.tenancy_id
  compartment_id = var.compartment_id

  home_region = var.home_region
  region      = var.region

  label_prefix = var.label_prefix

  ssh_private_key_path = var.ssh_private_key_path
  ssh_public_key_path  = var.ssh_public_key_path

  ssh_private_key = var.ssh_private_key
  ssh_public_key  = var.ssh_public_key

  # Configuramos un node pool sencillo
  node_pools = {
    np1 = {
      shape            = "VM.Standard.E4.Flex"
      ocpus            = 1
      memory           = 8
      node_pool_size   = 1
      boot_volume_size = 100
    }
  }

  # Puedes ajustar más parámetros: red, CNI, LB, etc.
  providers = {
    oci      = oci
    oci.home = oci.home
  }
}
