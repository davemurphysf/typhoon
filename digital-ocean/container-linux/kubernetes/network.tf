resource "digitalocean_firewall" "workers" {
  name = "${var.cluster_name}-workers"

  tags = ["${var.cluster_name}-worker"]

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
      source_tags = ["${digitalocean_tag.controllers.name}", "${digitalocean_tag.workers.name}", "${digitalocean_tag.load_balancer.name}", "${digitalocean_tag.db.name}"]
    },
    {
      protocol    = "tcp"
      port_range  = "all"
      source_tags = ["${digitalocean_tag.controllers.name}", "${digitalocean_tag.workers.name}", "${digitalocean_tag.load_balancer.name}", "${digitalocean_tag.db.name}"]
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
      source_tags = ["${digitalocean_tag.controllers.name}", "${digitalocean_tag.workers.name}", "${digitalocean_tag.load_balancer.name}", "${digitalocean_tag.db.name}"]
    },
    {
      protocol    = "tcp"
      port_range  = "all"
      source_tags = ["${digitalocean_tag.controllers.name}", "${digitalocean_tag.workers.name}", "${digitalocean_tag.load_balancer.name}", "${digitalocean_tag.db.name}"]
    }
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

resource "digitalocean_firewall" "lb" {
  name = "${var.cluster_name}-lb"

  tags = ["${var.cluster_name}-load_balancer"]

  # allow ssh, http/https ingress, and peer-to-peer traffic
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
    }
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

resource "digitalocean_firewall" "db" {
  name = "${var.cluster_name}-db"

  tags = ["${var.cluster_name}-db"]

  inbound_rule = [
    {
      protocol         = "tcp"
      port_range       = "22"
      source_addresses = ["0.0.0.0/0", "::/0"]
    },
    {
      protocol    = "udp"
      port_range  = "all"
      source_tags = ["${digitalocean_tag.controllers.name}", "${digitalocean_tag.workers.name}"]
    },
    {
      protocol    = "tcp"
      port_range  = "all"
      source_tags = ["${digitalocean_tag.controllers.name}", "${digitalocean_tag.workers.name}"]
    }
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