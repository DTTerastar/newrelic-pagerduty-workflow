variable "newrelic_account_id" {
  type        = number
  description = "The NewRelic account to create resources under"
}

variable "pagerduty_service_name" {
  type        = string
  description = "The name of the PagerDuty service to route NR notifications to"
}

variable "pagerduty_integration_key" {
  type        = string
  description = "The integration key for the PagerDuty service to integrate with"
}

variable "newrelic_alert_tag_name" {
  type        = string
  description = "The name of the NR alert condition tag that should be used to filter alerts"
  default     = "pagerduty"
  nullable    = false
}

variable "newrelic_alert_tag_values" {
  type        = list(string)
  description = "The values of the NR alert condition tag that should be used to filter alerts"
  default     = []
}

variable "newrelic_alert_policy_ids" {
  type        = list(string)
  description = "The ids of the NR policies that should be used to filter alerts"
  default     = []
}

variable "enabled" {
  type        = bool
  description = "Enables or disables the integration workflow"
  default     = true
}
