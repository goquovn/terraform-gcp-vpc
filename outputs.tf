output "vpc_name" {
  description = "VPC name."
  value       = google_compute_network.vpc.name
}
output "public_subnet_name" {
  description = "List public subnet name."
  value = [
    for ps in google_compute_subnetwork.public_subnet : ps.name
  ]
}
output "private_subnet_name" {
  description = "List private subnet name."
  value = [
    for ps in google_compute_subnetwork.private_subnet : ps.name
  ]
}

output "network" {
  description = "A reference (self_link) to the VPC network."
  value       = google_compute_network.vpc.self_link
}