#resource "signalfx_list_chart" "list_chart" {}
#resource "signalfx_single_value_chart" "sv_chart" {}
#resource "signalfx_time_chart" "time_chart" {}



# ----- Row 0

resource "signalfx_single_value_chart" "request_rate" {
    color_by                = "Dimension"
    description             = "Requests/sec processed by the service"
    is_timestamp_hidden     = false
    max_delay               = 0
    max_precision           = 4
    name                    = "Request rate"
    program_text            = "A = data('service.request.count', filter=filter('sf_environment', '*') and filter('sf_service', '${var.service_name}') and (not filter('sf_dimensionalized', '*')), rollup='rate').sum().publish(label='A')"
    secondary_visualization = "None"
    show_spark_line         = false
    timezone                = null
    unit_prefix             = "Metric"

    viz_options {
        color        = "lilac"
        display_name = "Requests/sec"
        label        = "A"
        value_prefix = null
        value_suffix = "requests/s"
        value_unit   = null
    }
}

resource "signalfx_time_chart" "request_rate" {
    axes_include_zero         = false
    axes_precision            = 0
    color_by                  = "Dimension"
    description               = "Requests/sec processed by the service"
    disable_sampling          = false
    max_delay                 = 0
    minimum_resolution        = 10
    name                      = "Request rate"
    on_chart_legend_dimension = null
    plot_type                 = "LineChart"
    program_text              = "C = data('service.request.count', filter=filter('sf_environment', '*') and filter('sf_service', '${var.service_name}') and (not filter('sf_dimensionalized', '*')), rollup='rate').sum(by=['sf_service', 'sf_environment']).publish(label='C')"
    show_data_markers         = false
    show_event_lines          = false
    stacked                   = false
    time_range                = 900
    timezone                  = null
    unit_prefix               = "Metric"

    histogram_options {
        color_theme = "red"
    }

    viz_options {
        axis         = "left"
        color        = "lilac"
        display_name = "Requests/sec"
        label        = "C"
        plot_type    = null
        value_prefix = null
        value_suffix = "requests/s"
        value_unit   = null
    }
}

# ----- Row 1

resource "signalfx_single_value_chart" "request_latency_p90" {
    color_by                = "Scale"
    description             = "90th percentile response time"
    is_timestamp_hidden     = false
    max_delay               = 0
    max_precision           = 5
    name                    = "Request latency (p90)"
    program_text            = <<-EOT
        def weighted_duration(base, p, filter_, groupby):
            error_durations     = data(base + '.duration.ns.' + p, filter=filter_ and filter('sf_error', 'true'),  rollup='max').mean(by=groupby, allow_missing=['sf_httpMethod'])
            non_error_durations = data(base + '.duration.ns.' + p, filter=filter_ and filter('sf_error', 'false'), rollup='max').mean(by=groupby, allow_missing=['sf_httpMethod'])
        
            error_counts     = data(base + '.count', filter=filter_ and filter('sf_error', 'true'),  rollup='sum').sum(by=groupby, allow_missing=['sf_httpMethod'])
            non_error_counts = data(base + '.count', filter=filter_ and filter('sf_error', 'false'), rollup='sum').sum(by=groupby, allow_missing=['sf_httpMethod'])
        
            error_weight     = (error_durations * error_counts).sum(over='1m')
            non_error_weight = (non_error_durations * non_error_counts).sum(over='1m')
        
            total_weight = combine((error_weight if error_weight is not None else 0) + (non_error_weight if non_error_weight is not None else 0))
            total = combine((error_counts if error_counts is not None else 0) + (non_error_counts if non_error_counts is not None else 0)).sum(over='1m')
            return (total_weight / total)
        
        filter_ = filter('sf_environment', '*') and filter('sf_service', '${var.service_name}') and not filter('sf_dimensionalized', '*')
        groupby = ['sf_service', 'sf_environment']
        weighted_duration('service.request', 'p90', filter_, groupby).mean().publish(label='p90')
    EOT
    secondary_visualization = "None"
    show_spark_line         = false
    timezone                = null
    unit_prefix             = "Metric"

    color_scale {
        color = "lime_green"
        gt    = 340282346638528860000000000000000000000
        gte   = 340282346638528860000000000000000000000
        lt    = 340282346638528860000000000000000000000
        lte   = 200000000
    }
    color_scale {
        color = "red"
        gt    = 400000000
        gte   = 340282346638528860000000000000000000000
        lt    = 340282346638528860000000000000000000000
        lte   = 340282346638528860000000000000000000000
    }
    color_scale {
        color = "vivid_yellow"
        gt    = 200000000
        gte   = 340282346638528860000000000000000000000
        lt    = 340282346638528860000000000000000000000
        lte   = 400000000
    }

    viz_options {
        color        = "green"
        display_name = "P90 response time"
        label        = "p90"
        value_prefix = null
        value_suffix = null
        value_unit   = "Nanosecond"
    }
}

resource "signalfx_time_chart" "request_latency_distribution" {
    axes_include_zero         = false
    axes_precision            = 0
    color_by                  = "Metric"
    description               = "Distribution of service response time with median (p50), 90th and 99th percentiles"
    disable_sampling          = false
    max_delay                 = 0
    minimum_resolution        = 10
    name                      = "Request latency distribution"
    on_chart_legend_dimension = null
    plot_type                 = "LineChart"
    program_text              = <<-EOT
        def weighted_duration(base, p, filter_, groupby):
            error_durations     = data(base + '.duration.ns.' + p, filter=filter_ and filter('sf_error', 'true'),  rollup='max').mean(by=groupby, allow_missing=['sf_httpMethod'])
            non_error_durations = data(base + '.duration.ns.' + p, filter=filter_ and filter('sf_error', 'false'), rollup='max').mean(by=groupby, allow_missing=['sf_httpMethod'])
        
            error_counts     = data(base + '.count', filter=filter_ and filter('sf_error', 'true'),  rollup='sum').sum(by=groupby, allow_missing=['sf_httpMethod'])
            non_error_counts = data(base + '.count', filter=filter_ and filter('sf_error', 'false'), rollup='sum').sum(by=groupby, allow_missing=['sf_httpMethod'])
        
            error_weight     = (error_durations * error_counts).sum(over='1m')
            non_error_weight = (non_error_durations * non_error_counts).sum(over='1m')
        
            total_weight = combine((error_weight if error_weight is not None else 0) + (non_error_weight if non_error_weight is not None else 0))
            total = combine((error_counts if error_counts is not None else 0) + (non_error_counts if non_error_counts is not None else 0)).sum(over='1m')
            return (total_weight / total)
        
        filter_ = filter('sf_environment', '*') and filter('sf_service', '${var.service_name}') and not filter('sf_dimensionalized', '*')
        groupby = ['sf_service', 'sf_environment']
        weighted_duration('service.request', 'median', filter_, groupby).publish(label='median')
        weighted_duration('service.request', 'p90', filter_, groupby).publish(label='p90')
        weighted_duration('service.request', 'p99', filter_, groupby).publish(label='p99')
        
        # Please provide a detector ID to link to and uncomment the following line:
        alerts(detector_id="${signalfx_detector.latency_detector.id}").publish()
    EOT
    show_data_markers         = false
    show_event_lines          = false
    stacked                   = false
    time_range                = 900
    timezone                  = null
    unit_prefix               = "Metric"

    histogram_options {
        color_theme = "red"
    }

    viz_options {
        axis         = "left"
        color        = "blue"
        display_name = "P90 latency"
        label        = "p90"
        plot_type    = null
        value_prefix = null
        value_suffix = null
        value_unit   = "Nanosecond"
    }
    viz_options {
        axis         = "left"
        color        = "green"
        display_name = "Median latency"
        label        = "median"
        plot_type    = null
        value_prefix = null
        value_suffix = null
        value_unit   = "Nanosecond"
    }
    viz_options {
        axis         = "left"
        color        = "orange"
        display_name = "P99 latency"
        label        = "p99"
        plot_type    = null
        value_prefix = null
        value_suffix = null
        value_unit   = "Nanosecond"
    }
}

# ----- Row 2

resource "signalfx_single_value_chart" "error_rate" {
    color_by                = "Scale"
    description             = "Error rate on requests made to the service"
    is_timestamp_hidden     = false
    max_delay               = 0
    max_precision           = 2
    name                    = "Error rate"
    program_text            = <<-EOT
        filter_ = filter('sf_environment', '*') and filter('sf_service', '${var.service_name}') and (not filter('sf_dimensionalized', '*'))
        A = data('service.request.count', filter=filter_ and filter('sf_error', 'true'), rollup='delta').sum(by=['sf_environment', 'sf_service']).publish(label='A', enable=False)
        B = data('service.request.count', filter=filter_, rollup='delta').sum(by=['sf_environment', 'sf_service']).publish(label='B', enable=False)
        C = combine(100*((A if A is not None else 0) / B)).publish(label='C')
    EOT
    secondary_visualization = "None"
    show_spark_line         = false
    timezone                = null
    unit_prefix             = "Metric"

    color_scale {
        color = "light_green"
        gt    = 0
        gte   = 340282346638528860000000000000000000000
        lt    = 340282346638528860000000000000000000000
        lte   = 0.1
    }
    color_scale {
        color = "lime_green"
        gt    = 340282346638528860000000000000000000000
        gte   = 340282346638528860000000000000000000000
        lt    = 340282346638528860000000000000000000000
        lte   = 0
    }
    color_scale {
        color = "red"
        gt    = 5
        gte   = 340282346638528860000000000000000000000
        lt    = 340282346638528860000000000000000000000
        lte   = 340282346638528860000000000000000000000
    }
    color_scale {
        color = "vivid_yellow"
        gt    = 0.1
        gte   = 340282346638528860000000000000000000000
        lt    = 340282346638528860000000000000000000000
        lte   = 1
    }
    color_scale {
        color = "yellow"
        gt    = 1
        gte   = 340282346638528860000000000000000000000
        lt    = 340282346638528860000000000000000000000
        lte   = 5
    }

    viz_options {
        color        = null
        display_name = "Errors"
        label        = "A"
        value_prefix = null
        value_suffix = null
        value_unit   = null
    }
    viz_options {
        color        = null
        display_name = "Requests"
        label        = "B"
        value_prefix = null
        value_suffix = null
        value_unit   = null
    }
    viz_options {
        color        = "pink"
        display_name = "Error rate"
        label        = "C"
        value_prefix = null
        value_suffix = "%"
        value_unit   = null
    }
}

resource "signalfx_time_chart" "error_rate" {
    axes_include_zero         = false
    axes_precision            = 0
    color_by                  = "Dimension"
    description               = "Error rate on requests made to the service"
    disable_sampling          = false
    max_delay                 = 0
    minimum_resolution        = 10
    name                      = "Error rate"
    on_chart_legend_dimension = null
    plot_type                 = "LineChart"
    program_text              = <<-EOT
        filter_ = filter('sf_environment', '*') and filter('sf_service', '${var.service_name}') and (not filter('sf_dimensionalized', '*'))
        A = data('service.request.count', filter=filter_ and filter('sf_error', 'true'), rollup='delta').sum(by=['sf_environment', 'sf_service']).publish(label='A', enable=False)
        B = data('service.request.count', filter=filter_, rollup='delta').sum(by=['sf_environment', 'sf_service']).publish(label='B', enable=False)
        C = combine(100*((A if A is not None else 0) / B)).publish(label='C')
        
        # Please provide a detector ID to link to and uncomment the following line:
        alerts(detector_id="${signalfx_detector.error_rate_detector.id}").publish()
    EOT
    show_data_markers         = false
    show_event_lines          = false
    stacked                   = false
    time_range                = 900
    timezone                  = null
    unit_prefix               = "Metric"

    axis_left {
        high_watermark       = 179769313486231570000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
        high_watermark_label = null
        label                = "%"
        low_watermark        = -179769313486231570000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
        low_watermark_label  = null
        max_value            = 179769313486231570000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
        min_value            = -179769313486231570000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
    }

    histogram_options {
        color_theme = "red"
    }

    viz_options {
        axis         = "left"
        color        = null
        display_name = "Errors"
        label        = "A"
        plot_type    = null
        value_prefix = null
        value_suffix = null
        value_unit   = null
    }
    viz_options {
        axis         = "left"
        color        = null
        display_name = "Requests"
        label        = "B"
        plot_type    = null
        value_prefix = null
        value_suffix = null
        value_unit   = null
    }
    viz_options {
        axis         = "left"
        color        = "pink"
        display_name = "Error rate"
        label        = "C"
        plot_type    = null
        value_prefix = null
        value_suffix = "%"
        value_unit   = null
    }
}


# ----- Row 3

resource "signalfx_heatmap_chart" "top_endpoints_by_latency" {
    description        = "Slowest service endpoints (1-minute latency average)"
    disable_sampling   = false
    group_by           = []
    hide_timestamp     = false
    max_delay          = 30
    minimum_resolution = 0
    name               = "Top endpoints by latency"
    program_text       = <<-EOT
        filter_ = filter('sf_environment', '*') and filter('sf_service', '${var.service_name}') and filter('sf_operation', '*') and filter('sf_kind', 'SERVER', 'CONSUMER') and (not filter('sf_dimensionalized', '*')) and (not filter('sf_serviceMesh', '*'))
        groupby = ['sf_environment', 'sf_service', 'sf_operation', 'sf_httpMethod']
        allow_missing = ['sf_httpMethod']
        
        A = histogram('spans', filter=filter_).percentile(pct=90, by=groupby, allow_missing=allow_missing).mean(over='1m').scale(0.000001).top(count=20).publish(label='A')
    EOT
    timezone           = null
    unit_prefix        = "Metric"

    color_range {
        color     = "#a747ff"
        max_value = 0
        min_value = 0
    }
}

resource "signalfx_list_chart" "top_endpoints_by_latency" {
    color_by                = "Scale"
    description             = "Slowest service endpoints (1-minute latency average)"
    disable_sampling        = false
    hide_missing_values     = false
    max_delay               = 30
    max_precision           = 0
    name                    = "Top endpoints by latency"
    program_text            = <<-EOT
        filter_ = filter('sf_environment', '*') and filter('sf_service', '${var.service_name}') and filter('sf_operation', '*') and filter('sf_kind', 'SERVER', 'CONSUMER') and (not filter('sf_dimensionalized', '*')) and (not filter('sf_serviceMesh', '*'))
        groupby = ['sf_environment', 'sf_service', 'sf_operation', 'sf_httpMethod']
        allow_missing = ['sf_httpMethod']
        
        A = histogram('spans', filter=filter_).percentile(pct=90, by=groupby, allow_missing=allow_missing).mean(over='1m').scale(0.000001).top(count=10).publish(label='A')
    EOT
    secondary_visualization = "None"
    sort_by                 = "-value"
    time_range              = 900
    timezone                = null
    unit_prefix             = "Metric"

    color_scale {
        color = "lime_green"
        gt    = 340282346638528860000000000000000000000
        gte   = 340282346638528860000000000000000000000
        lt    = 340282346638528860000000000000000000000
        lte   = 200
    }
    color_scale {
        color = "red"
        gt    = 1000
        gte   = 340282346638528860000000000000000000000
        lt    = 340282346638528860000000000000000000000
        lte   = 340282346638528860000000000000000000000
    }
    color_scale {
        color = "vivid_yellow"
        gt    = 200
        gte   = 340282346638528860000000000000000000000
        lt    = 340282346638528860000000000000000000000
        lte   = 1000
    }

    legend_options_fields {
        enabled  = false
        property = "sf_originatingMetric"
    }
    legend_options_fields {
        enabled  = false
        property = "sf_metric"
    }
    legend_options_fields {
        enabled  = false
        property = "sf_environment"
    }
    legend_options_fields {
        enabled  = true
        property = "sf_operation"
    }
    legend_options_fields {
        enabled  = true
        property = "sf_httpMethod"
    }
    legend_options_fields {
        enabled  = true
        property = "sf_service"
    }

    viz_options {
        color        = null
        display_name = "p90"
        label        = "A"
        value_prefix = null
        value_suffix = null
        value_unit   = "Millisecond"
    }
}

resource "signalfx_time_chart" "top_endpoints_by_latency" {
    axes_include_zero         = false
    axes_precision            = 0
    color_by                  = "Dimension"
    description               = "Slowest service endpoints (1-minute latency average)"
    disable_sampling          = false
    max_delay                 = 30
    minimum_resolution        = 0
    name                      = "Top endpoints by latency"
    on_chart_legend_dimension = "sf_operation"
    plot_type                 = "ColumnChart"
    program_text              = <<-EOT
        filter_ = filter('sf_environment', '*') and filter('sf_service', '${var.service_name}') and filter('sf_operation', '*') and filter('sf_kind', 'SERVER', 'CONSUMER') and (not filter('sf_dimensionalized', '*')) and (not filter('sf_serviceMesh', '*'))
        groupby = ['sf_environment', 'sf_service', 'sf_operation', 'sf_httpMethod']
        allow_missing = ['sf_httpMethod']
        
        A = histogram('spans', filter=filter_).percentile(pct=90, by=groupby, allow_missing=allow_missing).mean(over='1m').scale(0.000001).top(count=10).publish(label='A')
    EOT
    show_data_markers         = false
    show_event_lines          = false
    stacked                   = false
    time_range                = 900
    timezone                  = null
    unit_prefix               = "Metric"

    histogram_options {
        color_theme = "red"
    }

    legend_options_fields {
        enabled  = false
        property = "sf_originatingMetric"
    }
    legend_options_fields {
        enabled  = false
        property = "sf_metric"
    }
    legend_options_fields {
        enabled  = false
        property = "sf_environment"
    }
    legend_options_fields {
        enabled  = true
        property = "sf_operation"
    }
    legend_options_fields {
        enabled  = true
        property = "sf_httpMethod"
    }
    legend_options_fields {
        enabled  = true
        property = "sf_service"
    }

    viz_options {
        axis         = "left"
        color        = null
        display_name = "p90"
        label        = "A"
        plot_type    = null
        value_prefix = null
        value_suffix = null
        value_unit   = "Millisecond"
    }
}



# ----- Row 4

resource "signalfx_heatmap_chart" "top_endpoints_by_error_rate" {
    description        = "Most erroneous service endpoints (1-minute error rate average)"
    disable_sampling   = false
    group_by           = []
    hide_timestamp     = false
    max_delay          = 30
    minimum_resolution = 0
    name               = "Top endpoints by error rate"
    program_text       = <<-EOT
        filter_ = filter('sf_environment', '*') and filter('sf_service', '${var.service_name}') and filter('sf_operation', '*') and filter('sf_kind', 'SERVER', 'CONSUMER') and (not filter('sf_dimensionalized', '*')) and (not filter('sf_serviceMesh', '*'))
        groupby = ['sf_environment', 'sf_service', 'sf_operation', 'sf_httpMethod']
        allow_missing = ['sf_httpMethod']
        
        A = histogram('spans', filter=filter_ and filter('sf_error', 'true')).count(by=groupby, allow_missing=allow_missing).fill(0).publish(label='A', enable=False)
        B = histogram('spans', filter=filter_).count(by=groupby, allow_missing=allow_missing).fill(0).publish(label='B', enable=False)
        C = combine(100*((A if A is not None else 0) / B)).mean(over='1m').top(count=20).publish(label='C')
    EOT
    timezone           = null
    unit_prefix        = "Metric"

    color_scale {
        color = "lime_green"
        gt    = 340282346638528860000000000000000000000
        gte   = 340282346638528860000000000000000000000
        lt    = 340282346638528860000000000000000000000
        lte   = 0.1
    }
    color_scale {
        color = "red"
        gt    = 0.5
        gte   = 340282346638528860000000000000000000000
        lt    = 340282346638528860000000000000000000000
        lte   = 340282346638528860000000000000000000000
    }
    color_scale {
        color = "vivid_yellow"
        gt    = 0.1
        gte   = 340282346638528860000000000000000000000
        lt    = 340282346638528860000000000000000000000
        lte   = 0.5
    }
}

resource "signalfx_list_chart" "top_endpoints_by_error_rate" {
    color_by                = "Scale"
    description             = "Most erroneous service endpoints (1-minute error rate average)"
    disable_sampling        = false
    hide_missing_values     = true
    max_delay               = 30
    max_precision           = 0
    name                    = "Top endpoints by error rate"
    program_text            = <<-EOT
        filter_ = filter('sf_environment', '*') and filter('sf_service', '${var.service_name}') and filter('sf_operation', '*') and filter('sf_kind', 'SERVER', 'CONSUMER') and (not filter('sf_dimensionalized', '*')) and (not filter('sf_serviceMesh', '*'))
        groupby = ['sf_environment', 'sf_service', 'sf_operation', 'sf_httpMethod']
        allow_missing = ['sf_httpMethod']
        
        A = histogram('spans', filter=filter_ and filter('sf_error', 'true')).count(by=groupby, allow_missing=allow_missing).fill(0).publish(label='A', enable=False)
        B = histogram('spans', filter=filter_).count(by=groupby, allow_missing=allow_missing).fill(0).publish(label='B', enable=False)
        C = combine(100*((A if A is not None else 0) / B)).mean(over='1m').top(count=10).publish(label='C')
    EOT
    secondary_visualization = "None"
    sort_by                 = "-value"
    time_range              = 900
    timezone                = null
    unit_prefix             = "Metric"

    color_scale {
        color = "lime_green"
        gt    = 340282346638528860000000000000000000000
        gte   = 340282346638528860000000000000000000000
        lt    = 340282346638528860000000000000000000000
        lte   = 0.1
    }
    color_scale {
        color = "red"
        gt    = 0.5
        gte   = 340282346638528860000000000000000000000
        lt    = 340282346638528860000000000000000000000
        lte   = 340282346638528860000000000000000000000
    }
    color_scale {
        color = "vivid_yellow"
        gt    = 0.1
        gte   = 340282346638528860000000000000000000000
        lt    = 340282346638528860000000000000000000000
        lte   = 0.5
    }

    legend_options_fields {
        enabled  = false
        property = "sf_originatingMetric"
    }
    legend_options_fields {
        enabled  = false
        property = "sf_metric"
    }
    legend_options_fields {
        enabled  = false
        property = "sf_environment"
    }
    legend_options_fields {
        enabled  = true
        property = "sf_operation"
    }
    legend_options_fields {
        enabled  = true
        property = "sf_httpMethod"
    }
    legend_options_fields {
        enabled  = true
        property = "sf_service"
    }

    viz_options {
        color        = null
        display_name = "Error rate"
        label        = "C"
        value_prefix = null
        value_suffix = "%"
        value_unit   = null
    }
    viz_options {
        color        = null
        display_name = "Errors"
        label        = "A"
        value_prefix = null
        value_suffix = null
        value_unit   = null
    }
    viz_options {
        color        = null
        display_name = "Requests"
        label        = "B"
        value_prefix = null
        value_suffix = null
        value_unit   = null
    }
}

resource "signalfx_time_chart" "top_endpoints_by_error_rate" {
    axes_include_zero         = false
    axes_precision            = 0
    color_by                  = "Dimension"
    description               = "Most erroneous service endpoints (1-minute error rate average)"
    disable_sampling          = false
    max_delay                 = 30
    minimum_resolution        = 0
    name                      = "Top endpoints by error rate"
    on_chart_legend_dimension = null
    plot_type                 = "ColumnChart"
    program_text              = <<-EOT
        filter_ = filter('sf_environment', '*') and filter('sf_service', '${var.service_name}') and filter('sf_operation', '*') and filter('sf_kind', 'SERVER', 'CONSUMER') and (not filter('sf_dimensionalized', '*')) and (not filter('sf_serviceMesh', '*'))
        groupby = ['sf_environment', 'sf_service', 'sf_operation', 'sf_httpMethod']
        allow_missing = ['sf_httpMethod']
        
        A = histogram('spans', filter=filter_ and filter('sf_error', 'true')).count(by=groupby, allow_missing=allow_missing).fill(0).publish(label='A', enable=False)
        B = histogram('spans', filter=filter_).count(by=groupby, allow_missing=allow_missing).fill(0).publish(label='B', enable=False)
        C = combine(100*((A if A is not None else 0) / B)).mean(over='1m').top(count=10).publish(label='C')
    EOT
    show_data_markers         = false
    show_event_lines          = false
    stacked                   = false
    time_range                = 900
    timezone                  = null
    unit_prefix               = "Metric"

    histogram_options {
        color_theme = "red"
    }

    legend_options_fields {
        enabled  = false
        property = "sf_originatingMetric"
    }
    legend_options_fields {
        enabled  = false
        property = "sf_metric"
    }
    legend_options_fields {
        enabled  = false
        property = "sf_environment"
    }
    legend_options_fields {
        enabled  = true
        property = "sf_operation"
    }
    legend_options_fields {
        enabled  = true
        property = "sf_httpMethod"
    }
    legend_options_fields {
        enabled  = true
        property = "sf_service"
    }

    viz_options {
        axis         = "left"
        color        = null
        display_name = "Error rate"
        label        = "C"
        plot_type    = null
        value_prefix = null
        value_suffix = "%"
        value_unit   = null
    }
    viz_options {
        axis         = "left"
        color        = null
        display_name = "Errors"
        label        = "A"
        plot_type    = null
        value_prefix = null
        value_suffix = null
        value_unit   = null
    }
    viz_options {
        axis         = "left"
        color        = null
        display_name = "Requests"
        label        = "B"
        plot_type    = null
        value_prefix = null
        value_suffix = null
        value_unit   = null
    }
}


