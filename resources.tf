locals {
  vps_ip     = concat(digitalocean_droplet.terraform-do[*].ipv4_address)
  aws_prefix  = keys(var.devs)
  aws_image = values(var.devs)
  outs_count = length(var.devs)
}

resource "random_string" "password" {
  count   = length(var.devs)
  length  = "12"
  upper   = true
  lower   = true
  numeric = true
  special = false
}

resource "digitalocean_droplet" "terraform-do" {
  count    = length(var.devs)
  image    = element(local.aws_image, count.index)
  name     = element(local.aws_prefix, count.index)
  region   = var.do_region
  size     = var.do_size
  ssh_keys = [data.digitalocean_ssh_key.rebrain_key.fingerprint, digitalocean_ssh_key.do_my_key.fingerprint]
  tags     = [var.email, var.task, var.module]

  connection {
    type        = var.conn_type
    user        = var.conn_user
    host        = self.ipv4_address
    timeout     = "50s"
    private_key = file(var.priv_rsa_path)
  }

  provisioner "remote-exec" {
    inline = [
      "echo ${var.do_login}:${element(random_string.password[*].result, count.index)} | chpasswd",
      "sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config",
      "systemctl restart sshd"
    ]
  }
}

resource "digitalocean_ssh_key" "do_my_key" {
  name       = "do_my_key"
  public_key = var.do_my_ssh
}

resource "local_file" "output_file" {
  content  = templatefile(var.temp_file_path, {
    ip     = digitalocean_droplet.terraform-do[*].ipv4_address,
    passwd = random_string.password[*].result,
    dns    = aws_route53_record.devops_4038_dns[*].name
  })
  filename = var.output_file_path
}

resource "local_file" "ans_inventory" {
  content  = templatefile(var.ans_temp_file_path, {
    ans_ip      = "${digitalocean_droplet.terraform-do[*].ipv4_address}",
    ans_passwd  = "${random_string.password[*].result}",
    ans_user    = "${var.conn_user}",
    ans_host    = "${aws_route53_record.devops_4038_dns[*].name}"
  })
  filename = var.invent_file_path
}

resource "aws_route53_record" "devops_4038_dns" {
  count     = length(var.devs)
  zone_id   = data.aws_route53_zone.r53_zone.zone_id
  name      = "${element(local.aws_prefix, count.index)}.${(var.aws_name)}"
  type      = "A"
  ttl       = "300"
  records   = [local.vps_ip[count.index]]
}
