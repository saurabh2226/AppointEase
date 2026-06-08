variable "project" {
  type = string
}
variable "env" {
  type = string
}
variable "subnet_ids" {
  type = list(string)
}
variable "security_group_id" {
  type = string
}
variable "instance_class" {
  type = string
}
variable "storage" {
  type    = number
  default = 20
}
variable "db_name" {
  type = string
}
variable "db_username" {
  type = string
}
variable "db_password" {
  type      = string
  sensitive = true
}
