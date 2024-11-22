terraform {
  required_providers {
    signalfx = {
      source = "splunk-terraform/signalfx"
      version = "9.2.1"
    }
  }
}

provider "signalfx" {
  auth_token = var.auth_token
  api_url="https://api.${var.realm}.signalfx.com"
}
