output "lb_root_passwd" {
  value = random_string.lb_password[*].result
  #sensitive = true
}

output "app_root_passwd" {
  value = random_string.app_password[*].result
  #sensitive = true
}

# output "count" {
#   value = local.vps_count
# }

# output "aws_image" {
#   value = local.aws_image[*]
# }

# output "aws_prefix" {
#   value = local.aws_prefix[*]
# }

# output "user_passwd" {
#   value = local.do_user_passwd[*]
# }