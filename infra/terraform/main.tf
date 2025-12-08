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

data "oci_identity_availability_domains" "ads" {
  compartment_id = var.tenancy_id
}

data "oci_core_images" "oracle_linux_latest" {
  compartment_id   = var.compartment_id
  operating_system = "Oracle Linux"
  operating_system_version = "8"   # ← MUY IMPORTANTE
  shape = "VM.Standard2.1"         # ← OBLIGA A COMPATIBILIDAD
  sort_by          = "TIMECREATED"
  sort_order       = "DESC"
}

# -------------------------------------------------------------
# NETWORK
# -------------------------------------------------------------

resource "oci_core_vcn" "main" {
  cidr_block     = "10.0.0.0/16"
  display_name   = "hotel-vcn"
  compartment_id = var.compartment_id
}

resource "oci_core_internet_gateway" "igw" {
  compartment_id = var.compartment_id
  display_name   = "hotel-igw"
  vcn_id         = oci_core_vcn.main.id
  enabled        = true
}

resource "oci_core_default_route_table" "rt" {
  manage_default_resource_id = oci_core_vcn.main.default_route_table_id

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.igw.id
  }
}

resource "oci_core_subnet" "public" {
  cidr_block                 = "10.0.1.0/24"
  display_name               = "hotel-public-subnet"
  compartment_id             = var.compartment_id
  vcn_id                     = oci_core_vcn.main.id
  prohibit_public_ip_on_vnic = false
}

# -------------------------------------------------------------
# COMPUTE INSTANCE — VM PARA DOCKER
# -------------------------------------------------------------

resource "oci_core_instance" "hotel_vm" {
  compartment_id      = var.compartment_id
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name

  shape        = "VM.Standard2.1"
  display_name = "hotel-app-server"

  create_vnic_details {
    subnet_id        = oci_core_subnet.public.id
    assign_public_ip = true
  }

  metadata = {
    ssh_authorized_keys = file(var.ssh_public_key_path)
    user_data           = base64encode(templatefile("cloud_init.sh", {}))
  }

  source_details {
  source_type = "image"
  source_id   = data.oci_core_images.oracle_linux_latest.images[0].id
}

}

# -------------------------------------------------------------
# OUTPUT
# -------------------------------------------------------------

output "public_ip" {
  value = oci_core_instance.hotel_vm.public_ip
}
