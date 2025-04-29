variable "server_ip" {
  description = "Public IP of the remote server"
  type        = string
}

variable "server_user" {
  description = "SSH username for the remote server"
  type        = string
}

# Tunnel 1 Configuration
variable "leftid_tunnel1" {
  description = "Customer Gateway ID for Tunnel1"
  type        = string
}

variable "rightid_tunnel1" {
  description = "Virtual Private Gateway ID for Tunnel1"
  type        = string
}

# Tunnel 2 Configuration
variable "leftid_tunnel2" {
  description = "Customer Gateway ID for Tunnel2"
  type        = string
}

variable "rightid_tunnel2" {
  description = "Virtual Private Gateway ID for Tunnel2"
  type        = string
}

# Common Subnet Configuration
variable "leftsubnet" {
  description = "Left subnet for both tunnels"
  type        = string
}

variable "rightsubnet" {
  description = "Right subnet for both tunnels"
  type        = string
}

# Tunnel 1 VPN Secrets
variable "customer_public_ip" {
  description = "Customer side public IP for secrets (Tunnel1)"
  type        = string
}

variable "aws_vgw_public_ip" {
  description = "AWS VGW public IP for secrets (Tunnel1)"
  type        = string
}

variable "shared_secret" {
  description = "Pre-shared key for Tunnel1 VPN"
  type        = string
}

# Tunnel 2 VPN Secrets
variable "customer_public_ip2" {
  description = "Customer side public IP for secrets (Tunnel2)"
  type        = string
}

variable "aws_vgw_public_ip2" {
  description = "AWS VGW public IP for secrets (Tunnel2)"
  type        = string
}

variable "shared_secret2" {
  description = "Pre-shared key for Tunnel2 VPN"
  type        = string
}