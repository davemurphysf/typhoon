# load_balancer DNS records
resource "digitalocean_record" "load_balancer" {
  count = "${var.load_balancer_count}"

  # DNS zone where record should be created
  domain = "${var.dns_zone}"

  name  = "${var.cluster_name}-load_balancer"
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
  depends_on = ["digitalocean_droplet.workers", "digitalocean_droplet.controllers"]
  count = "${var.load_balancer_count}"

  name   = "${var.cluster_name}-load_balancer-${count.index}"
  region = "${var.region}"

  image = "${var.image}"
  size  = "${var.load_balancer_type}"

  # network
  ipv6               = true
  private_networking = true

  ssh_keys  = "${var.ssh_fingerprints}"

  tags = [
    "${digitalocean_tag.load_balancer.id}",
  ]

  connection {
      user = "root"
      type = "ssh"
      private_key = "${file(var.pvt_key)}"
      timeout = "2m"
  }

  provisioner "remote-exec" {
    inline = [
      "export PATH=$PATH:/usr/bin",
      "curl -L http://nginx.org/keys/nginx_signing.key | sudo apt-key add -",
      "sudo add-apt-repository \"deb http://nginx.org/packages/mainline/ubuntu/\" $(lsb_release -s -c) main",
      "sudo apt-get update",
      "sudo apt-get -y install nginx"
    ]
  }

  provisioner "file" {
    content     = "${data.template_file.load_balancer_config.rendered}"
    destination = "/etc/nginx/nginx.conf"
  }
}

# Tag to label load_balancer
resource "digitalocean_tag" "load_balancer" {
  name = "${var.cluster_name}-load_balancer"
}

# load_balancer Container Linux Config
data "template_file" "load_balancer_config" {
  template = "${var.nginx_conf}"

  vars = {
    k8s_api  = "${formatlist("server %s:%s;\n", digitalocean_droplet.workers.*.ipv4_address), var.api_port}"
    k8s_auth = "${formatlist("server %s:%s;\n", digitalocean_droplet.workers.*.ipv4_address), var.auth_port}"
    k8s_core = "${formatlist("server %s:%s;\n", digitalocean_droplet.workers.*.ipv4_address), var.auth_core}"
  }
}
