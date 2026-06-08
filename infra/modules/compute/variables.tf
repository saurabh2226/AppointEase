variable "project" {
  type = string
}
variable "env" {
  type = string
}
variable "ami_id" {
  type = string
}
variable "instance_type" {
  type = string
}
variable "security_group_id" {
  type = string
}
variable "subnet_ids" {
  type = list(string)
}
variable "asg_desired" {
  type    = number
  default = 1
}
variable "asg_min" {
  type    = number
  default = 1
}
variable "asg_max" {
  type    = number
  default = 3
}
variable "target_group_arn" {
  type = string
}
variable "repo_url" {
  type = string
}
variable "database_url" {
  type      = string
  sensitive = true
}
variable "redis_url" {
  type      = string
  sensitive = true
}
variable "secret_key" {
  type      = string
  sensitive = true
}
variable "smtp_user" {
  type    = string
  default = ""
}
variable "smtp_pass" {
  type      = string
  sensitive = true
  default   = ""
}
variable "razorpay_key_id" {
  type    = string
  default = ""
}
variable "razorpay_key_secret" {
  type      = string
  sensitive = true
  default   = ""
}
variable "frontend_url" {
  type = string
}
variable "backend_url" {
  type = string
}
