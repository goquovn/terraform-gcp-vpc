locals {
  all_subnet                = setunion(var.private_subnets, var.public_subnets)
  vpc_private_subnets_cidrs = { for s in var.private_subnets : index(var.private_subnets, s) => s }
  vpc_public_subnets_cidrs  = { for s in var.public_subnets : index(var.public_subnets, s) => s }

}
resource "google_compute_network" "vpc" {
  name                    = format("%s", "${var.project}-${var.env}-vpc-tf")
  project                 = var.project_id
  auto_create_subnetworks = "false"
  routing_mode            = "GLOBAL"
}
resource "google_compute_firewall" "allow-internal" {
  name    = "${var.project}-fw-allow-internal"
  network = google_compute_network.vpc.name
  allow {
    protocol = "icmp"
  }
  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }
  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }
  source_ranges = local.all_subnet
}
resource "google_compute_firewall" "allow-http" {
  name    = "${var.project}-fw-allow-http"
  network = google_compute_network.vpc.name
  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
  target_tags   = ["http"]
  source_ranges = ["0.0.0.0/0"]
}
resource "google_compute_firewall" "allow-https" {
  name    = "${var.project}-fw-allow-https"
  network = google_compute_network.vpc.name
  allow {
    protocol = "tcp"
    ports    = ["443"]
  }
  target_tags   = ["https"]
  source_ranges = ["0.0.0.0/0"]
}
resource "google_compute_firewall" "allow-bastion" {
  name    = "${var.project}-fw-allow-bastion"
  network = google_compute_network.vpc.name
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  target_tags = ["ssh"]
  source_tags = ["ssh"]
}
resource "google_compute_subnetwork" "public_subnet" {
  for_each      = local.vpc_public_subnets_cidrs
  name          = format("%s%s", "${var.project}-${var.env}-${var.region_name}-pubnet-tf", each.key + 1)
  ip_cidr_range = each.value
  network       = google_compute_network.vpc.id
  region        = var.region_name
  #  secondary_ip_range = [for r in var.vpc_secondary_ip_ranges : r.secondary_range]

}
resource "google_compute_subnetwork" "private_subnet" {
  for_each           = local.vpc_private_subnets_cidrs
  name               = format("%s%s", "${var.project}-${var.env}-${var.region_name}-privnet-tf", each.key + 1)
  ip_cidr_range      = each.value
  network            = google_compute_network.vpc.id
  region             = var.region_name
  secondary_ip_range = [for r in var.vpc_secondary_ip_ranges : r.secondary_range]

}

resource "google_compute_global_address" "private_ip_address" {
  name          = "private-ip-address-tf"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.vpc.id
}

#resource "google_service_networking_connection" "private_vpc_connection" {
#  network                 = google_compute_network.vpc.id
#  service                 = "servicenetworking.googleapis.com"
#  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
#}
