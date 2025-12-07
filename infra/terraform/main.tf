terraform {
  required_version = ">= 1.3.0"

  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 4.54.0"
    }
  }
}

# -------------------------------------------------------------------
# 1. PROVIDERS
# -------------------------------------------------------------------

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

# -------------------------------------------------------------------
# 2. OKE MODULE (version 5.3.3)
# -------------------------------------------------------------------

module "oke" {
  source  = "oracle-terraform-modules/oke/oci"
  version = "5.3.3"

  tenancy_id     = var.tenancy_id
  compartment_id = var.compartment_id

  region      = var.region
  home_region = var.home_region

  # El módulo 5.3.3 NO soporta label_prefix → lo aplicamos manualmente
  vcn_name   = "${var.label_prefix}-vcn"
  vcn_cidr   = "10.0.0.0/16"
  create_vcn = true

  control_plane_type = "public"

  # SSH KEYS (por ruta)
  ssh_public_key_path  = var.ssh_public_key_path
  ssh_private_key_path = var.ssh_private_key_path

  # Node Pool simple y estable
  worker_node_pool_size = 1
  worker_node_shape      = "VM.Standard.E4.Flex"
  worker_node_ocpus      = 1
  worker_node_memory     = 8

  providers = {
    oci      = oci
    oci.home = oci.home
  }
}

# -------------------------------------------------------------------
# 3. OUTPUTS
# -------------------------------------------------------------------

output "cluster_id" {
  value = module.oke.cluster_id
}
