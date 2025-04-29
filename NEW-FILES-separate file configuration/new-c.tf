provider "local" {}
provider "null" {}

# Create separate configuration files for Tunnel1 and Tunnel2
resource "local_file" "tunnel1_conf" {
  content = <<EOL
conn Tunnel1
  authby=secret
  auto=start
  left=%defaultroute
  leftid=${var.leftid_tunnel1}
  right=${var.rightid_tunnel1}
  type=tunnel
  ikelifetime=8h
  keylife=1h
  keyexchange=ike
  leftsubnet=${var.leftsubnet}
  rightsubnet=${var.rightsubnet}
  dpddelay=10
  dpdtimeout=30
  dpdaction=restart_by_peer
EOL

  filename = "${path.module}/files/tunnel1.conf"
}

resource "local_file" "tunnel2_conf" {
  content = <<EOL
conn Tunnel2
  authby=secret
  auto=start
  left=%defaultroute
  leftid=${var.leftid_tunnel2}
  right=${var.rightid_tunnel2}
  type=tunnel
  ikelifetime=8h
  keylife=1h
  keyexchange=ike
  leftsubnet=${var.leftsubnet}
  rightsubnet=${var.rightsubnet}
  dpddelay=10
  dpdtimeout=30
  dpdaction=restart_by_peer
EOL

  filename = "${path.module}/files/tunnel2.conf"
}

# Create separate secrets files for Tunnel1 and Tunnel2
resource "local_file" "tunnel1_secrets" {
  content = <<EOL
${var.customer_public_ip} ${var.aws_vgw_public_ip}: PSK "${var.shared_secret}"
EOL

  filename = "${path.module}/files/tunnel1.secrets"
}

resource "local_file" "tunnel2_secrets" {
  content = <<EOL
${var.customer_public_ip2} ${var.aws_vgw_public_ip2}: PSK "${var.shared_secret2}"
EOL

  filename = "${path.module}/files/tunnel2.secrets"
}

# Install Libreswan if not already installed
resource "null_resource" "install_libreswan" {
  provisioner "remote-exec" {
    inline = [
      "if ! command -v ipsec >/dev/null 2>&1; then sudo yum update && sudo yum install -y libreswan; else echo 'Libreswan already installed'; fi",
      "sudo systemctl enable ipsec",
      "sudo systemctl start ipsec"
    ]
    connection {
      type        = "ssh"
      host        = var.server_ip
      user        = var.server_user
      private_key = file("/home/ec2-user/tanish.pem")
    }
  }
}

# Modify ipsec.conf to include all files in /etc/ipsec.d/
resource "null_resource" "modify_ipsec_conf" {
  depends_on = [null_resource.install_libreswan]
  provisioner "remote-exec" {
    inline = [
      "if ! grep -q 'include /etc/ipsec.d/*.conf' /etc/ipsec.conf; then echo 'include /etc/ipsec.d/*.conf' | sudo tee -a /etc/ipsec.conf; fi"
    ]
    connection {
      type        = "ssh"
      host        = var.server_ip
      user        = var.server_user
      private_key = file("/home/ec2-user/tanish.pem")
    }
  }
}

# Update sysctl.conf for IP forwarding
resource "null_resource" "update_sysctl_conf" {
  depends_on = [null_resource.modify_ipsec_conf]
  provisioner "remote-exec" {
    inline = [
      "echo 'net.ipv4.ip_forward = 1' | sudo tee -a /etc/sysctl.conf",
      "echo 'net.ipv4.conf.all.accept_redirects = 0' | sudo tee -a /etc/sysctl.conf",
      "echo 'net.ipv4.conf.all.send_redirects = 0' | sudo tee -a /etc/sysctl.conf",
      "sudo sysctl -p",
      "sudo systemctl restart systemd-networkd"
    ]
    connection {
      type        = "ssh"
      host        = var.server_ip
      user        = var.server_user
      private_key = file("/home/ec2-user/tanish.pem")
    }
  }
}

# Configure the Tunnel1 conf file on the remote server
resource "null_resource" "configure_tunnel1_conf" {
  depends_on = [null_resource.update_sysctl_conf, local_file.tunnel1_conf]
  provisioner "remote-exec" {
    inline = [
      "echo '${local_file.tunnel1_conf.content}' | sudo tee /etc/ipsec.d/tunnel1.conf"
    ]
    connection {
      type        = "ssh"
      host        = var.server_ip
      user        = var.server_user
      private_key = file("/home/ec2-user/tanish.pem")
    }
  }
}

# Configure the Tunnel2 conf file on the remote server
resource "null_resource" "configure_tunnel2_conf" {
  depends_on = [null_resource.update_sysctl_conf, local_file.tunnel2_conf]
  provisioner "remote-exec" {
    inline = [
      "echo '${local_file.tunnel2_conf.content}' | sudo tee /etc/ipsec.d/tunnel2.conf"
    ]
    connection {
      type        = "ssh"
      host        = var.server_ip
      user        = var.server_user
      private_key = file("/home/ec2-user/tanish.pem")
    }
  }
}

# Configure Tunnel1 secrets
resource "null_resource" "configure_tunnel1_secrets" {
  depends_on = [null_resource.configure_tunnel1_conf, local_file.tunnel1_secrets]
  provisioner "remote-exec" {
    inline = [
      "echo '${local_file.tunnel1_secrets.content}' | sudo tee /etc/ipsec.d/tunnel1.secrets"
    ]
    connection {
      type        = "ssh"
      host        = var.server_ip
      user        = var.server_user
      private_key = file("/home/ec2-user/tanish.pem")
    }
  }
}

# Configure Tunnel2 secrets
resource "null_resource" "configure_tunnel2_secrets" {
  depends_on = [null_resource.configure_tunnel2_conf, local_file.tunnel2_secrets]
  provisioner "remote-exec" {
    inline = [
      "echo '${local_file.tunnel2_secrets.content}' | sudo tee /etc/ipsec.d/tunnel2.secrets"
    ]
    connection {
      type        = "ssh"
      host        = var.server_ip
      user        = var.server_user
      private_key = file("/home/ec2-user/tanish.pem")
    }
  }
}

# Restart IPsec service and bring up the tunnels
resource "null_resource" "start_ipsec_service" {
  depends_on = [
    null_resource.configure_tunnel1_secrets,
    null_resource.configure_tunnel2_secrets
  ]
  provisioner "remote-exec" {
    inline = [
      "sudo systemctl enable ipsec",
      "sudo systemctl restart ipsec",
      # Remove interactive systemctl status
      #"sudo systemctl status ipsec",
      "sleep 5",  # (optional) give IPsec some time to come up
      "sudo ipsec auto --up Tunnel1",
      "sudo ipsec auto --up Tunnel2"
    ]
    connection {
      type        = "ssh"
      host        = var.server_ip
      user        = var.server_user
      private_key = file("/home/ec2-user/tanish.pem")
    }
  }
}
