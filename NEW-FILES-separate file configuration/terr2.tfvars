server_ip           = "13.232.205.206" # Public IP of the server
server_user         = "ec2-user" # SSH username for the server

# Tunnel 1 Details
leftid_tunnel1      = "13.232.205.206" # Customer Gateway ID for Tunnel1
rightid_tunnel1     = "34.193.133.67" # Virtual Private Gateway ID for Tunnel1

# Tunnel 2 Details
leftid_tunnel2      = "13.232.205.206" # Customer Gateway ID for Tunnel2
rightid_tunnel2     = "34.206.60.184" # Virtual Private Gateway ID for Tunnel2

# Subnet Details
leftsubnet          = "10.1.0.0/16" # Left subnet for both tunnels
rightsubnet         = "10.0.0.0/16" # Right subnet for both tunnels

# Tunnel 1 VPN Secrets
customer_public_ip  = "13.232.205.206" # Customer side public IP for secrets (Tunnel1)
aws_vgw_public_ip   = "34.193.133.67" # AWS VGW public IP for secrets (Tunnel1)

shared_secret       = "LHy52pA62JpYk0ieq08eMxZlk00LtHc3" # Pre-shared key for Tunnel1 VPN

# Tunnel 2 VPN Secrets
customer_public_ip2  = "13.232.205.206" # Customer side public IP for secrets (Tunnel2)
aws_vgw_public_ip2   = "34.206.60.184" # AWS VGW public IP for secrets (Tunnel2)

shared_secret2      = "_KAW.sDDnjWLgwdN726wozdFPSDIr1Yp" # Pre-shared key for Tunnel2 VPN
