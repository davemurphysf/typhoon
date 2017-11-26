output "controllers_dns" {
  value = "${digitalocean_record.controllers.0.fqdn}"
}

output "workers_dns" {
  value = "${digitalocean_record.workers.0.fqdn}"
}

output "controllers_ipv4" {
  value = ["${digitalocean_droplet.controllers.*.ipv4_address}"]
}

output "controllers_ipv6" {
  value = ["${digitalocean_droplet.controllers.*.ipv6_address}"]
}

output "workers_ipv4" {
  value = ["${digitalocean_droplet.workers.*.ipv4_address}"]
}

output "workers_ipv6" {
  value = ["${digitalocean_droplet.workers.*.ipv6_address}"]
}

output "load_balancers_ipv4" {
  value = ["${digitalocean_droplet.load_balancers.*.ipv4_address}"]
}

output "load_balancers_ipv6" {
  value = ["${digitalocean_droplet.load_balancers.*.ipv6_address}"]
}

output "floating_ip" {
  value = "${digitalocean_floating_ip.load_balancers.ip_address}"
}

output "asset_dir" {
  value = "${var.asset_dir}"
}

output "cluster_name" {
  value = "${var.cluster_name}"
}