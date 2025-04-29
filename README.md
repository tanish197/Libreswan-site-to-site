# Libreswan Site-to-Site VPN Setup

## Installing Terraform and Configuring EC2 for SSH Access

This guide provides comprehensive instructions for:

- Installing Terraform on a Linux-based EC2 instance (Amazon Linux 2, Ubuntu, or Debian).
- Adding your PEM private key to the instance for secure SSH access.
- Preparing your environment for a Libreswan-based site-to-site VPN, including necessary network and security configurations.

---

## 1. Install Terraform

### For Amazon Linux 2 or RHEL-based Distributions (CentOS, Fedora)

**Update the system:**
```bash
sudo yum update -y
```

**Install required dependencies:**
```bash
sudo yum install -y yum-utils
```

**Add the HashiCorp repository:**
```bash
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
```

**Install Terraform:**
```bash
sudo yum install terraform -y
```

**Verify the installation:**
```bash
terraform --version
```

---

### For Ubuntu or Debian-based Distributions

**Update the system:**
```bash
sudo apt-get update -y
```

**Install required dependencies:**
```bash
sudo apt-get install -y gnupg software-properties-common curl
```

**Add the HashiCorp GPG key:**
```bash
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
```

**Add the HashiCorp repository:**
```bash
sudo apt-add-repository "deb https://apt.releases.hashicorp.com $(lsb_release -cs) main"
```

**Update the package index and install Terraform:**
```bash
sudo apt-get update -y
sudo apt-get install terraform -y
```

**Verify the installation:**
```bash
terraform --version
```

---

### Manual Installation (Alternative Method)

**Download the latest Terraform release:**

Visit [Terraform Downloads](https://www.terraform.io/downloads) and get the appropriate version, or:

```bash
wget https://releases.hashicorp.com/terraform/1.5.0/terraform_1.5.0_linux_amd64.zip
```

**Unzip and move the binary:**
```bash
unzip terraform_1.5.0_linux_amd64.zip
sudo mv terraform /usr/local/bin/
```

**Verify the installation:**
```bash
terraform --version
```

---

## 2. Add PEM Private Key for SSH Access

**Copy your PEM private key to the EC2 instance (if needed) and set proper permissions:**
```bash
chmod 777 /path/to/your-key.pem
```

---

## 3. VPN Configuration Prerequisites (Libreswan Site-to-Site)

To successfully establish a site-to-site VPN using Libreswan, complete the following networking and security tasks:

### ✅ On the On-Premises Side:

- **Open UDP ports 500 and 4500 in the firewall/security gateway** to allow IPsec IKE and NAT-T traffic:


- **Add a static route to the AWS side via the VPN tunnel interface or ENI:**
  
  Example:
  ```bash
  sudo ip route add <AWS_VPC_CIDR> via <VPN_Tunnel_IP>
  ```

  Replace `<AWS_VPC_CIDR>` with your AWS VPC’s CIDR block, and `<VPN_Tunnel_IP>` with the IP address of the tunnel interface connected to AWS.

---

### ✅ On the AWS Side:

- **Attach a Virtual Private Gateway (VGW)** to the target VPC:
  - Use the AWS Console or Terraform to create and attach the VGW.
  - Associate the route table of the VPC with the VGW for routing VPN traffic.

- **Ensure security groups and network ACLs allow IPsec traffic** (UDP 500, 4500) and ESP protocol (IP Protocol 50), if applicable.

---

## 4. Notes on Private Key Usage

In a VPN context, the term *private shared key* typically refers to one of the following:

- **Private Key (Asymmetric)** – Used in IPsec/IKE authentication or SSH. This should remain secure on your EC2 or on-prem server.
- **Pre-Shared Key (Symmetric)** – Shared manually between the two VPN peers. Used for IKE Phase 1 authentication.

Ensure that any sensitive key material (private or shared) is stored securely and never exposed publicly.

---

## 5. Example Next Steps (Terraform + Libreswan)

Once Terraform is installed and your environment is secured:

- Use Terraform to provision EC2 instances, VPCs, and the VPN configuration.
- Configure Libreswan on each side to define the IPsec tunnel.
- Validate connectivity using `ping`, `traceroute`, and Libreswan logs (`/var/log/secure`, `ipsec status`).

---
