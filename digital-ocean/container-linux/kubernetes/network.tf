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
      source_tags = ["${var.worker_firewall_tag_names}"]
    },
    {
      protocol    = "tcp"
      port_range  = "all"
      source_tags = ["${var.worker_firewall_tag_names}"]
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
      source_tags = ["${var.controller_firewall_tag_names}"]
    },
    {
      protocol    = "tcp"
      port_range  = "all"
      source_tags = ["${var.controller_firewall_tag_names}"]
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



