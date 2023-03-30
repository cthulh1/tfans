locals {
  app_prefix      = keys(var.app_srv)
  app_image    = values(var.app_srv)
  app_count       = length(var.app_srv)
  app_user_passwd = random_string.app_password[*].result
  lb_vps_ip      = digitalocean_droplet.lb_vps[*].ipv4_address
  lb_prefix       = keys(var.lb_srv)
  lb_image        = values(var.lb_srv)
  lb_count        = length(var.lb_srv)
  lb_user_passwd  = random_string.lb_password[*].result
}

resource "random_string" "app_password" {
  count   = local.app_count
  length  = "12"
  upper   = true
  lower   = true
  numeric = true
  special = false
}

resource "random_string" "lb_password" {
  count   = local.lb_count
  length  = "12"
  upper   = true
  lower   = true
  numeric = true
  special = false
}

resource "digitalocean_droplet" "lb_vps" {
  count    = local.lb_count
  image    = element(local.lb_image, count.index)
  name     = element(local.lb_prefix, count.index)
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
      "echo ${var.do_login}:${element(local.lb_user_passwd[*], count.index)} | chpasswd",
      "sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config",
      "systemctl restart sshd",
    ]
  }
}

resource "digitalocean_droplet" "app_vps" {
  count    = local.app_count
  image    = element(local.app_image, count.index)
  name     = element(local.app_prefix, count.index)
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
      "echo ${var.do_login}:${element(local.app_user_passwd[*], count.index)} | chpasswd",
      "sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config",
      "systemctl restart sshd",
    ]
  }
}

resource "digitalocean_ssh_key" "do_my_key" {
  name       = "do_my_key"
  public_key = var.do_my_ssh
}

resource "local_file" "output_file" {
  content  = templatefile(var.temp_file_path, {
    app_ip     = digitalocean_droplet.app_vps[*].ipv4_address,
    app_passwd = random_string.app_password[*].result,
    lb_dns     = aws_route53_record.devops_4038_dns[*].name,
    lb_ip      = digitalocean_droplet.lb_vps[*].ipv4_address,
    lb_passwd  = random_string.lb_password[*].result
  })
  filename = var.output_file_path
}

resource "local_file" "ans_inventory" {
  content  = templatefile(var.ans_temp_file_path, {
    ans_app_ip     = digitalocean_droplet.app_vps[*].ipv4_address,
    ans_lb_ip      = digitalocean_droplet.lb_vps[*].ipv4_address,
    ans_host_user  = var.do_user,
    ans_user       = var.conn_user,
    ans_host       = aws_route53_record.devops_4038_dns[*].name
  })
  filename = var.invent_file_path
}

resource "aws_route53_record" "devops_4038_dns" {
  count     = local.lb_count
  zone_id   = data.aws_route53_zone.r53_zone.zone_id
  name      = "${element(local.lb_prefix, count.index)}.${(var.aws_name)}"
  type      = "A"
  ttl       = "300"
  records   = [local.lb_vps_ip[count.index]]
}

resource "null_resource" "check_file" {
  triggers = { 
    file_exists = fileexists(local_file.ans_inventory.filename) 
  }
}

resource "null_resource" "run_ansible_pb" {
  provisioner "local-exec" {
    command = "ansible-playbook playbook.yml"
  }
  depends_on = [null_resource.check_file]
}
