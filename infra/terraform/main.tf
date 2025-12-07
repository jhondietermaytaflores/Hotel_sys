terraform {
  required_version = ">= 1.3.0"

  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 4.54.0"
    }
  }
}

provider "oci" {
  tenancy_ocid = var.tenancy_id
  user_ocid    = var.user_id
  fingerprint  = var.api_fingerprint
  private_key  = var.api_private_key
  region       = var.region
}

# -------------------------------------------------------------------
#  OKE MODULE (OCIR official)
# -------------------------------------------------------------------

module "oke" {
  source  = "oracle/oke/oci"
  version = "4.4.0"

  # Required
  compartment_id = var.compartment_id

  cluster_name = "${var.label_prefix}-cluster"

  # Create VCN automatically
  create_vcn = true

  # Pods network (CNI)
  cni_type = "OCI_VCN_IP_NATIVE"

  kubernetes_version = "v1.29.1" # versión estable

  # Public endpoint
  endpoint_config = {
    is_public_ip_enabled = true
  }

  # SSH keys (paths created in GitHub Actions runner)
  ssh_public_key_path  = var.ssh_public_key_path

  # Node Pool
  node_pools = {
    pool1 = {
      name               = "hotel-pool"
      shape              = "VM.Standard.E4.Flex"
      ocpus              = 1
      memory_in_gbs      = 8
      size               = 1
    }
  }
}


