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


# -------------------------------------------------------------
# DATA SOURCES
# -------------------------------------------------------------

# Availability domains
data "oci_identity_availability_domains" "ads" {
  compartment_id = var.tenancy_id
}

# Get valid images for workers
data "oci_core_images" "oke_images" {
  compartment_id           = var.compartment_id
  operating_system         = "Oracle Linux"
  operating_system_version = "9"
  shape                    = "VM.Standard.E4.Flex"
}

# -------------------------------------------------------------
# NETWORKING
# -------------------------------------------------------------

resource "oci_core_vcn" "main" {
  cidr_block     = "10.0.0.0/16"
  display_name   = "${var.label_prefix}-vcn"
  compartment_id = var.compartment_id
}

resource "oci_core_internet_gateway" "igw" {
  compartment_id = var.compartment_id
  display_name   = "${var.label_prefix}-igw"
  vcn_id         = oci_core_vcn.main.id
  enabled        = true
}

resource "oci_core_default_route_table" "rt" {
  manage_default_resource_id = oci_core_vcn.main.default_route_table_id

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.igw.id
    description       = "Internet access"
  }
}

resource "oci_core_subnet" "public" {
  cidr_block                 = "10.0.1.0/24"
  display_name               = "${var.label_prefix}-public-subnet"
  compartment_id             = var.compartment_id
  vcn_id                     = oci_core_vcn.main.id
  prohibit_public_ip_on_vnic = false
}

resource "oci_core_subnet" "private" {
  cidr_block                 = "10.0.2.0/24"
  display_name               = "${var.label_prefix}-private-subnet"
  compartment_id             = var.compartment_id
  vcn_id                     = oci_core_vcn.main.id
  prohibit_public_ip_on_vnic = true
}

# -------------------------------------------------------------
# OKE CLUSTER
# -------------------------------------------------------------

resource "oci_containerengine_cluster" "oke" {
  compartment_id     = var.compartment_id
  name               = "${var.label_prefix}-cluster"
  kubernetes_version = "v1.33.1"

  # Required
  vcn_id = oci_core_vcn.main.id

  endpoint_config {
    is_public_ip_enabled = true
    subnet_id            = oci_core_subnet.public.id
  }

  options {
    service_lb_subnet_ids = [oci_core_subnet.public.id]

    kubernetes_network_config {
      pods_cidr     = "10.244.0.0/16"
      services_cidr = "10.96.0.0/16"
    }
  }
}

# -------------------------------------------------------------
# DATA SOURCE FOR NODE POOL OPTIONS (MUST BE AFTER CLUSTER)
# -------------------------------------------------------------

data "oci_containerengine_node_pool_option" "options" {
  node_pool_option_id = oci_containerengine_cluster.oke.id
}

locals {
  oke_image = [
    for s in data.oci_containerengine_node_pool_option.options.sources :
    s.image_id
    if s.source_type == "IMAGE"
  ][0]
}


# -------------------------------------------------------------
# NODE POOL
# -------------------------------------------------------------

resource "oci_containerengine_node_pool" "pool1" {
  compartment_id     = var.compartment_id
  cluster_id         = oci_containerengine_cluster.oke.id
  name               = "${var.label_prefix}-nodepool"
  kubernetes_version = "v1.33.1"

  node_shape = "VM.Standard.E4.Flex"

  node_shape_config {
    ocpus         = 1
    memory_in_gbs = 8
  }

  ssh_public_key = file(var.ssh_public_key_path)

  # Imagen CERTIFICADA por OKE
  node_source_details {
    source_type = "IMAGE"
    image_id    = local.oke_image
  }

  node_config_details {
    size = 1

    placement_configs {
      availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
      subnet_id           = oci_core_subnet.private.id
    }
  }
}




