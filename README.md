# splunk_tfdash_apm_service_with_detectors

This script will create a dashboard group, a dashboard with multiple charts for a single APM service, and 2 detectors (for latency and error rate).

The latency and errors detectors are linked to the "Request Latency Distribution" and the "Error rate" charts, respectively.

The values for dashboard group name, apm service name, notification emails, and others are specified as variables (see terraform.tfvars.template).


1. Create your "terraform.tfvars" file from the template file: terraform.tfvars.template

    cp terraform.tfvars.template terraform.tfvars

2. Set the variables in the terraform.tfvars file

Replace "<AUTH_TOKEN>" with your API token from Splunk Observability Cloud.
Replace "<ORG_ID>" with the ORG ID from Splunk Observability Cloud.
Replace "<realm>" with the realm from Splunk Observability Cloud.

    auth_token = <AUTH_TOKEN>
    org_id = <ORG_ID>
    realm = <realm>

Specify values for the other variables:

    service_name = "Example Service"
    dashboard_group_name = "Splunk Terraform"
    default_environment = "prd"
    notification_emails = ["Email,email1@exampleemail123.com","Email,email1@exampleemail123.com"]


3. Run terraform init

4. terraform plan

5. terraform apply

