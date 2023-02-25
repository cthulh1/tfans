output "user_passwd" {
  value = random_string.password[*].result
  #sensitive = true
}


output "count" {
  value = length(var.devs)
}
