resource "signalfx_dashboard_group" "service_dashboards_dg" {
    description = null
    name        = var.dashboard_group_name
    teams       = []

    permissions {
        actions        = [
            "READ",
            "WRITE",
        ]
        principal_id   = var.org_id
        principal_type = "ORG"
    }
}