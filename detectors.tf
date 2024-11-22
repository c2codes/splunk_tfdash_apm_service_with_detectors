resource "signalfx_detector" "latency_detector" {
    description        = null
    detector_origin    = "Standard"
    disable_sampling   = false
    name               = "${var.service_name} Latency Detector"
    parent_detector_id = null
    program_text       = <<-EOT
        from signalfx.detectors.apm.latency.static_v2 import static as latency_static_v2
        latency_static_v2.detector(clear_lasting=None, clear_threshold=400, exclude_errors=True, filter_=(filter('sf_environment', 'prd') and filter('sf_service', '${var.service_name}')), fire_lasting=lasting('1m', 0.5), fire_threshold=400, pctile=90, resource_type='service', volume_relative_threshold=0, volume_static_threshold=0).publish('${var.service_name} Latency Detector')
    EOT
    show_data_markers  = true
    show_event_lines   = false
    tags               = []
    teams              = []
    timezone           = null

    rule {
        description           = null
        detect_label          = "${var.service_name} Latency Detector"
        disabled              = false
        notifications         = var.notification_emails
        parameterized_body    = <<-EOT
            {{#if anomalous}}
                Rule "{{{ruleName}}}" triggered at {{dateTimeFormat timestamp format="full"}}.
            {{else}}
                Rule "{{{ruleName}}}" cleared at {{dateTimeFormat timestamp format="full"}}.
            {{/if}}
            
            {{#if anomalous}}Signal value for {{dimensions.app}} in {{dimensions.sf_environment}} is out of bounds
            {{else}}Current signal value for {{dimensions.app}} in {{dimensions.sf_environment}}{{/if}}
            
            {{#notEmpty dimensions}}
            Signal details:
            {{{dimensions}}}
            {{/notEmpty}}
            
            {{#if anomalous}}
            {{#if runbookUrl}}Runbook: {{{runbookUrl}}}{{/if}}
            {{#if tip}}Tip: {{{tip}}}{{/if}}
            {{/if}}
        EOT
        parameterized_subject = "{{ruleSeverity}} Alert: {{{ruleName}}}"
        runbook_url           = null
        severity              = "Critical"
        tip                   = null
    }
}

resource "signalfx_detector" "error_rate_detector" {
    description        = null
    detector_origin    = "Standard"
    disable_sampling   = false
    name               = "${var.service_name} Error Rate"
    parent_detector_id = null
    program_text       = <<-EOT
        from signalfx.detectors.apm.errors.static_v2 import static as errors_sudden_static_v2
        errors_sudden_static_v2.detector(attempt_threshold=1, clear_rate_threshold=0.001, current_window='5m', filter_=(filter('sf_environment', 'prd') and filter('sf_service', '${var.service_name}')), fire_rate_threshold=0.002, resource_type='service').publish('${var.service_name} Error Rate')
    EOT
    show_data_markers  = true
    show_event_lines   = false
    tags               = []
    teams              = []
    timezone           = null

    rule {
        description           = null
        detect_label          = "${var.service_name} Error Rate"
        disabled              = false
        notifications         = var.notification_emails
        parameterized_body    = <<-EOT
            {{#if anomalous}}
                Rule "{{{ruleName}}}" triggered at {{dateTimeFormat timestamp format="full"}}.
            {{else}}
                Rule "{{{ruleName}}}" cleared at {{dateTimeFormat timestamp format="full"}}.
            {{/if}}
            
            {{#if anomalous}}Signal value for {{dimensions.app}} in {{dimensions.sf_environment}} is out of bounds
            {{else}}Current signal value for {{dimensions.app}} in {{dimensions.sf_environment}}{{/if}}
            
            {{#notEmpty dimensions}}
            Signal details:
            {{{dimensions}}}
            {{/notEmpty}}
            
            {{#if anomalous}}
            {{#if runbookUrl}}Runbook: {{{runbookUrl}}}{{/if}}
            {{#if tip}}Tip: {{{tip}}}{{/if}}
            {{/if}}
        EOT
        parameterized_subject = "{{ruleSeverity}} Alert: {{{ruleName}}}"
        runbook_url           = null
        severity              = "Critical"
        tip                   = null
    }
}
