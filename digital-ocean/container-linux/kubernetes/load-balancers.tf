# load_balancer DNS records
resource "digitalocean_record" "load_balancer" {
  count = "${var.load_balancer_count}"

  # DNS zone where record should be created
  domain = "${var.dns_zone}"

  name  = "${var.cluster_name}-lb"
  type  = "A"
  ttl   = 300
  value = "${element(digitalocean_droplet.load_balancers.*.ipv4_address, count.index)}"
}

resource "digitalocean_floating_ip" "load_balancers" {
  droplet_id = "${digitalocean_droplet.load_balancers.0.id}"
  region     = "${digitalocean_droplet.load_balancers.0.region}"
}

# load_balancer droplet instances
resource "digitalocean_droplet" "load_balancers" {
  depends_on = ["digitalocean_droplet.workers", "digitalocean_droplet.controllers", "null_resource.bootkube-start"]
  count = "${var.load_balancer_count}"

  name   = "${var.cluster_name}-lb-${count.index}"
  region = "${var.region}"

  image = "${var.load_balancer_image}"
  size  = "${var.load_balancer_type}"

  # network
  ipv6               = true
  private_networking = true

  ssh_keys  = "${var.ssh_fingerprints}"

  tags = [
    "${digitalocean_tag.load_balancer.id}"
  ]

  connection {
      user = "root"
      type = "ssh"
      timeout = "2m"
  }

  provisioner "remote-exec" {
    inline = [
      "export PATH=$PATH:/usr/bin",
      "curl -L http://nginx.org/keys/nginx_signing.key | sudo apt-key add -",
      "echo \"deb http://nginx.org/packages/mainline/ubuntu/ xenial nginx\" | sudo tee /etc/apt/sources.list.d/nginx.list",
      "echo \"deb-src http://nginx.org/packages/mainline/ubuntu/ xenial nginx\" | sudo tee -a /etc/apt/sources.list.d/nginx.list",
      "sudo apt-get update && sudo apt-get upgrade -y",
      "sudo apt-get -y install nginx",
      "sudo rm -rf /etc/nginx/sites-enabled"
    ]
  }

  provisioner "file" {
    content     = "${data.template_file.load_balancer_config.rendered}"
    destination = "/etc/nginx/nginx.conf"
  }

  provisioner "file" {
    content = "${file("${var.client_cert_path}")}"
    destination = "/etc/nginx/client-origin.pem"
  }

  provisioner "file" {
    content = "${file("${var.origin_cert_path}")}"
    destination = "/etc/nginx/origin.cert"
  }

  provisioner "file" {
    content = "${file("${var.origin_key_path}")}"
    destination = "/etc/nginx/origin.key"
  }

  provisioner "remote-exec" {
    inline = [
      "export PATH=$PATH:/usr/bin",
      "systemctl start nginx.service",
      "curl -sSL https://agent.digitalocean.com/install.sh | sh"
    ]
  }
}

# Tag to label load_balancer
resource "digitalocean_tag" "load_balancer" {
  name = "${var.cluster_name}-load_balancer"
}

data "template_file" "load_balancer_config" {
  template = "${file("${var.nginx_conf_path}")}"

  vars {
    k8s = "${join("\n", formatlist("server %s;", digitalocean_droplet.workers.*.ipv4_address_private))}"
  }
}
