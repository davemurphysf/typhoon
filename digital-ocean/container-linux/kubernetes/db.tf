# db DNS records
resource "digitalocean_record" "db" {
  # DNS zone where record should be created
  domain = "${var.dns_zone}"

  name  = "${var.cluster_name}-db"
  type  = "A"
  ttl   = 300
  value = "${digitalocean_droplet.db.ipv4_address_private}"
}

# db droplet instance
resource "digitalocean_droplet" "db" {
  name   = "${var.cluster_name}-db"
  region = "${var.region}"

  image = "${var.db_image}"
  size  = "${var.db_type}"

  # network
  ipv6               = true
  private_networking = true

  ssh_keys  = "${var.ssh_fingerprints}"

  tags = [
    "${digitalocean_tag.db.id}"
  ]

  connection {
      user = "root"
      type = "ssh"
      timeout = "2m"
  }

  provisioner "remote-exec" {
    inline = [
        "export PATH=$PATH:/usr/bin",
        "sudo apt-get update && sudo apt-get upgrade -y && sudo apt autoremove -y",
        "sudo apt-get -y install postgresql postgresql-contrib python3-pip",
        "sudo -u postgres psql -c \"CREATE USER ${var.db_user} WITH CREATEDB CREATEROLE CREATEUSER INHERIT LOGIN REPLICATION NOBYPASSRLS ENCRYPTED PASSWORD '${var.db_password}' VALID UNTIL 'infinity';\"",
        "sudo -u postgres psql -c \"CREATE DATABASE ${var.db_database_name} OWNER ${var.db_user};\""
    ]
  }
}

resource "null_resource" "db-setup" {

  connection {
    type    = "ssh"
    host    = "${digitalocean_droplet.db.ipv4_address}"
    user    = "root"
    timeout = "10m"
  }

  provisioner "file" {
    content     = "${data.template_file.postgres_config.rendered}"
    destination = "/etc/postgresql/9.5/main/postgresql.conf"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo systemctl restart postgresql.service",
      "pip3 install --upgrade pip",
      "pip install wal-e[aws,azure,google,swift]",
      "curl -sSL https://agent.digitalocean.com/install.sh | sh"
    ]
  }
}

# Tag to label load_balancer
resource "digitalocean_tag" "db" {
  name = "${var.cluster_name}-db"
}


data "template_file" "postgres_config" {
  template = "${file("${var.db_postgres_conf_path}")}"

  vars {
    private_ip = "${digitalocean_droplet.db.ipv4_address_private}"
  }
}