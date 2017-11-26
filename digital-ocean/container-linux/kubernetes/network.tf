resource "digitalocean_firewall" "workers" {
  name = "${var.cluster_name}-workers"

  tags = ["${var.cluster_name}-worker"]

  depends_on = ["digitalocean_droplet.workers"]

  inbound_rule = [
    {
      protocol         = "tcp"
      port_range       = "22"
      source_addresses = ["0.0.0.0/0", "::/0"]
    },
     {
      protocol         = "tcp"
      port_range       = "443"
      source_addresses = ["0.0.0.0/0", "::/0"]
    },
    {
      protocol    = "udp"
      port_range  = "all"
      source_tags = ["${digitalocean_tag.controllers.name}", "${digitalocean_tag.workers.name}", "${digitalocean_tag.load_balancer.name}"]
    },
    {
      protocol    = "tcp"
      port_range  = "all"
      source_tags = ["${digitalocean_tag.controllers.name}", "${digitalocean_tag.workers.name}", "${digitalocean_tag.load_balancer.name}"]
    },
  ]

  outbound_rule = [
    {
      protocol              = "icmp"
      destination_addresses = ["0.0.0.0/0", "::/0"]
    },
    {
      protocol              = "udp"
      port_range            = "all"
      destination_addresses = ["0.0.0.0/0", "::/0"]
    },
    {
      protocol              = "tcp"
      port_range            = "all"
      destination_addresses = ["0.0.0.0/0", "::/0"]
    },
  ]
}

resource "digitalocean_firewall" "controller" {
  name = "${var.cluster_name}-controllers"

  tags = ["${var.cluster_name}-controller"]

  depends_on = ["digitalocean_droplet.controllers"]

  inbound_rule = [
    {
      protocol         = "tcp"
      port_range       = "22"
      source_addresses = ["0.0.0.0/0", "::/0"]
    },
    {
      protocol         = "tcp"
      port_range       = "443"
      source_addresses = ["0.0.0.0/0", "::/0"]
    },
    {
      protocol    = "udp"
      port_range  = "all"
      source_tags = ["${digitalocean_tag.controllers.name}", "${digitalocean_tag.workers.name}", "${digitalocean_tag.load_balancer.name}"]
    },
    {
      protocol    = "tcp"
      port_range  = "all"
      source_tags = ["${digitalocean_tag.controllers.name}", "${digitalocean_tag.workers.name}", "${digitalocean_tag.load_balancer.name}"]
    },
  ]

  # allow all outbound traffic
  outbound_rule = [
    {
      protocol              = "icmp"
      destination_addresses = ["0.0.0.0/0", "::/0"]
    },
    {
      protocol              = "udp"
      port_range            = "all"
      destination_addresses = ["0.0.0.0/0", "::/0"]
    },
    {
      protocol              = "tcp"
      port_range            = "all"
      destination_addresses = ["0.0.0.0/0", "::/0"]
    },
  ]
}
