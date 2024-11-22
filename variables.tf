variable "service_name" {
  type = string
  default = "Example Service"
}

variable "dashboard_group_name" {
  type = string
  default = "Splunk Terraform"
}

variable "default_environment" {
  type = string
  default = "prd"
}

variable "auth_token" {
  type = string
}

variable "org_id" {
  type = string
}

variable "realm" {
  type = string
  default = "us1"
}


variable "notification_emails" {
  type = list
  default = []
}
