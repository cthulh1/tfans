output "user_passwd" {
  value = random_string.password[*].result
  #sensitive = true
}


output "count" {
  value = length(var.devs)
}

output "aws_image" {
  value = local.aws_image[*]
}

output "aws_prefix" {
  value = local.aws_prefix[*]
}
