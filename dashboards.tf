
# signalfx_dashboard.service_overview:
resource "signalfx_dashboard" "service_overview" {
    charts_resolution = "default"
    dashboard_group   = signalfx_dashboard_group.service_dashboards_dg.id
    description       = null
    name              = var.service_name


    # ----- Row 0

    chart {
        chart_id = signalfx_single_value_chart.request_rate.id
        column   = 0
        height   = 1
        row      = 0
        width    = 4
    }

    chart {
        chart_id = signalfx_time_chart.request_rate.id
        column   = 4
        height   = 1
        row      = 0
        width    = 8
    }

    # ----- Row 1
    
    chart {
        chart_id = signalfx_single_value_chart.request_latency_p90.id
        column   = 0
        height   = 1
        row      = 1
        width    = 4
    }

    chart {
        chart_id = signalfx_time_chart.request_latency_distribution.id
        column   = 4
        height   = 1
        row      = 1
        width    = 8
    }

    # ------ Row 2


    chart {
        chart_id = signalfx_single_value_chart.error_rate.id
        column   = 0
        height   = 1
        row      = 2
        width    = 4
    }
    
    chart {
        chart_id = signalfx_time_chart.error_rate.id
        column   = 4
        height   = 1
        row      = 2
        width    = 8
    }

    # ------ Row 3

    chart {
        chart_id = signalfx_heatmap_chart.top_endpoints_by_latency.id
        column   = 0
        height   = 1
        row      = 3
        width    = 3
    }

    chart {
        chart_id = signalfx_list_chart.top_endpoints_by_latency.id
        column   = 3
        height   = 1
        row      = 3
        width    = 3
    }

    chart {
        chart_id = signalfx_time_chart.top_endpoints_by_latency.id
        column   = 6
        height   = 1
        row      = 3
        width    = 6
    }

    # ----- Row 4

    chart {
        chart_id = signalfx_heatmap_chart.top_endpoints_by_error_rate.id
        column   = 0
        height   = 1
        row      = 4
        width    = 3
    }
    
    chart {
        chart_id = signalfx_list_chart.top_endpoints_by_error_rate.id
        column   = 3
        height   = 1
        row      = 4
        width    = 3
    }
    
    chart {
        chart_id = signalfx_time_chart.top_endpoints_by_error_rate.id
        column   = 6
        height   = 1
        row      = 4
        width    = 6
    }
    

    permissions {
        parent = signalfx_dashboard_group.service_dashboards_dg.id
    }

    variable {
        alias                  = "sf_environment"
        apply_if_exist         = false
        description            = null
        property               = "sf_environment"
        replace_only           = false
        restricted_suggestions = false
        value_required         = true
        values                 = [
            var.default_environment,
        ]
        values_suggested       = []
    }
}


