variable "project" {
  type    = string
  default = "appointease"
}
variable "db_name" {
  type    = string
  default = "appointease_dev"
}
variable "db_username" {
  type    = string
  default = "dbadmin"
}
variable "db_password" {
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
variable "ami_id" {
  type    = string
  default = "ami-0b4ca4c7a210c8dc6"
}
variable "alert_email" {
  type = string
}
