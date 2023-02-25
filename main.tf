data "digitalocean_ssh_key" "rebrain_key" {
  name = "REBRAIN.SSH.PUB.KEY"
}

data "aws_route53_zone" "r53_zone" {
  name = var.aws_zone
}
