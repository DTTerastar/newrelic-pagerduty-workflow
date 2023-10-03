resource "newrelic_notification_destination" "pagerduty_destination" {
  account_id = var.newrelic_account_id

  name = "${var.pagerduty_service_name} Destination"
  type = "PAGERDUTY_SERVICE_INTEGRATION"

  property {
    key   = ""
    value = ""
  }

  auth_token {
    prefix = "Token token="
    token  = var.pagerduty_integration_key
  }
}

resource "newrelic_notification_channel" "pagerduty_channel" {
  account_id = var.newrelic_account_id

  name           = "${var.pagerduty_service_name} Channel"
  type           = "PAGERDUTY_SERVICE_INTEGRATION"
  destination_id = newrelic_notification_destination.pagerduty_destination.id
  product        = "IINT"

  property {
    key   = "summary"
    value = "{{ annotations.title.[0] }}"
  }

  property {
    key   = "customDetails"
    value = <<-EOT
            {
            "id":{{json issueId}},
            "IssueURL":{{json issuePageUrl}},
            "NewRelic priority":{{json priority}},
            "Total Incidents":{{json totalIncidents}},
            "Impacted Entities":"{{#each entitiesData.names}}{{this}}{{#unless @last}}, {{/unless}}{{/each}}",
            "Runbook":"{{#each accumulations.runbookUrl}}{{this}}{{#unless @last}}, {{/unless}}{{/each}}",
            "Description":"{{#each annotations.description}}{{this}}{{#unless @last}}, {{/unless}}{{/each}}",
            "isCorrelated":{{json isCorrelated}},
            "Alert Policy Names":"{{#each accumulations.policyName}}{{this}}{{#unless @last}}, {{/unless}}{{/each}}",
            "Alert Condition Names":"{{#each accumulations.conditionName}}{{this}}{{#unless @last}}, {{/unless}}{{/each}}",
            "Workflow Name":{{json workflowName}}
            }
        EOT
  }
}

resource "newrelic_workflow" "pagerduty_workflow" {
  name                  = "${var.pagerduty_service_name} Workflow"
  muting_rules_handling = "NOTIFY_ALL_ISSUES"
  enabled               = var.enabled

  issues_filter {
    name = "Filter-name"
    type = "FILTER"

    predicate {
      attribute = "accumulations.tag.${var.newrelic_alert_tag}"
      operator  = "EXACTLY_MATCHES"
      values    = ["true"]
    }
  }

  destination {
    channel_id = newrelic_notification_channel.pagerduty_channel.id
  }
}

output "newrelic_pagerduty_integration" {
  value = {
    destination = {
      id   = newrelic_notification_destination.pagerduty_destination.id
      name = newrelic_notification_destination.pagerduty_destination.name
    }
    channel = {
      id   = newrelic_notification_channel.pagerduty_channel.id
      name = newrelic_notification_channel.pagerduty_channel.name
    }
    workflow = {
      id   = newrelic_workflow.pagerduty_workflow.id
      name = newrelic_workflow.pagerduty_workflow.name
    }
  }
}
