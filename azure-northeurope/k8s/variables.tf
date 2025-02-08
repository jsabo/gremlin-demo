variable "region" {
  description = "AWS Region of cluster"
  type        = string
  default     = "us-east-2"
}

variable "gremlin_team_id" {
  description = <<-DESC
    (Required) Team ID for Gremlin.
    Use the environment variable TF_VAR_gremlin_team_id if you prefer not to hard-code this value.
  DESC
  type        = string
  sensitive   = true
}

variable "gremlin_team_secret" {
  description = <<-DESC
    (Required) Team Secret for Gremlin.
    Use the environment variable TF_VAR_gremlin_team_secret if you prefer not to hard-code this value.
  DESC
  type        = string
  sensitive   = true
}

variable "gremlin_chart_version" {
  description = "Gremlin Helm Chart release version"
  type        = string
  default     = "0.19.0"
}

variable "otel_demo_chart_version" {
  description = "Opentelemetry Demo Helm Chart release version"
  type        = string
  default     = "0.32.8"
}

variable "datadog_api_key" {
  description = <<-DESC
    (Required) API Key for Datadog.
    Use the environment variable TF_VAR_datadog_api_key if you prefer not to hard-code this value.
  DESC
  type        = string
  sensitive   = true
}

variable "datadog_site" {
  description = <<-DESC
    (Optional) Datadog site. Defaults to "datadoghq.com" (US).
    Use the environment variable TF_VAR_datadog_site if you prefer not to hard-code this value.
  DESC
  type        = string
  default     = "datadoghq.com"
}

