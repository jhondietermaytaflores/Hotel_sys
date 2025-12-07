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
# NETWORK (VCN + SUBNETS)
# -------------------------------------------------------------------

resource "oci_core_vcn" "main" {
  cidr_block     = "10.0.0.0/16"
  compartment_id = var.compartment_id
  display_name   = "${var.label_prefix}-vcn"
}

resource "oci_core_subnet" "public" {
  cidr_block              = "10.0.1.0/24"
  vcn_id                  = oci_core_vcn.main.id
  compartment_id          = var.compartment_id
  display_name            = "${var.label_prefix}-public-subnet"
  prohibit_public_ip_on_vnic = false
}

resource "oci_core_subnet" "private" {
  cidr_block              = "10.0.2.0/24"
  vcn_id                  = oci_core_vcn.main.id
  compartment_id          = var.compartment_id
  display_name            = "${var.label_prefix}-private-subnet"
  prohibit_public_ip_on_vnic = true
}

resource "oci_core_internet_gateway" "igw" {
  display_name   = "${var.label_prefix}-igw"
  vcn_id         = oci_core_vcn.main.id
  compartment_id = var.compartment_id
}

resource "oci_core_default_route_table" "rt" {
  manage_default_resource_id = oci_core_vcn.main.default_route_table_id

  route_rules {
    network_entity_id = oci_core_internet_gateway.igw.id
    destination       = "0.0.0.0/0"
    description       = "Internet access"
  }
}

# -------------------------------------------------------------------
# OKE CLUSTER
# -------------------------------------------------------------------

resource "oci_containerengine_cluster" "oke" {
  compartment_id     = var.compartment_id
  name               = "${var.label_prefix}-cluster"
  vcn_id             = oci_core_vcn.main.id
  kubernetes_version = "v1.33.1"

  endpoint_config {
    is_public_ip_enabled = true
    subnet_id            = oci_core_subnet.public.id
  }

  options {
    service_lb_subnet_ids = [oci_core_subnet.public.id]
  }
}

# -------------------------------------------------------------------
# NODE POOL
# -------------------------------------------------------------------

resource "oci_containerengine_node_pool" "pool1" {
  compartment_id     = var.compartment_id
  cluster_id         = oci_containerengine_cluster.oke.id
  name               = "${var.label_prefix}-nodepool"
  kubernetes_version = "v1.33.1"
  node_shape         = "VM.Standard.E4.Flex"

  node_config_details {
    size = 1
    placement_configs {
      availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
      subnet_id           = oci_core_subnet.private.id
    }
  }

  node_shape_config {
    ocpus         = 1
    memory_in_gbs = 8
  }

  ssh_public_key = file(var.ssh_public_key_path)
}

# -------------------------------------------------------------------
# DATA SOURCE FOR ADs
# -------------------------------------------------------------------

data "oci_identity_availability_domains" "ads" {
  compartment_id = var.tenancy_id
}
