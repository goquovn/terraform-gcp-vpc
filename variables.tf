variable "env" {
  default = "dev"
}
variable "project" {
  description = "project name"
}
variable "project_id" {
  description = "google cloud project id"
  default     = null
}
variable "region_name" {
  description = "region name"
  default     = "asia-southeast1"
}
variable "public_subnets" {
  type        = list(string)
  default     = ["10.26.1.0/24"]
  description = "The list of public subnets being created"
}

variable "private_subnets" {
  type        = list(string)
  default     = []
  description = "The list of private subnets being created"
}
variable "vpc_secondary_ip_ranges" {
  type = map(object({
    secondary_range = object({
      range_name    = string
      ip_cidr_range = string
    })
  }))
  default = {
    gke-pods = {
      secondary_range = {
        range_name    = "gke-pods"
        ip_cidr_range = "192.168.64.0/22"
      }
    }
    gke-services = {
      secondary_range = {
        range_name    = "gke-services"
        ip_cidr_range = "192.168.1.0/24"
      }
    }
  }
}