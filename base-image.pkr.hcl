packer {
  required_plugins {
    amazon = {
      version = ">= 1.1.1"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "ubuntu" {
  ami_name      = "osquery-scale-packer-image-{{timestamp}}"
  instance_type = "t2.micro"
  region        = "us-east-1"
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username = "ubuntu"
  ## share with entire org
  #ami_org_arns = [
  #    "arn:aws:organizations::<account_id_root>:organization/<org-id>"
  #]
}

build {
  #remove if not using hcp packer
  hcp_packer_registry {
    bucket_name = "osquery-at-scale-packer-image"

    description = <<EOT
Golden image process with visibility baked into ubuntu for Osquery@scale
    EOT

    bucket_labels = {
      "team" = "ben.pruce@gmail.com",
      "os"   = "ubuntu - focal"
    }

    build_labels = {
      "build-time"   = timestamp()
      "build-source" = basename(path.cwd)
    }
  }
  name = "packer-base-osquery"
  sources = [
    "source.amazon-ebs.ubuntu"
  ]

  provisioner "shell" {
    scripts = [
      "./scripts/fluent-bit.sh",
      "./scripts/osquery.sh"
    ]
  }

  #copy local configs
  provisioner "file" {
    source      = "./root/etc"
    destination = "/tmp"
  }

  #Configure osquery, logrotate & fluent-bit
  provisioner "shell" {
    script = "./scripts/post_install.sh"
  }
}
