variable "region" {
  description = "AWS Region of cluster"
  type        = string
  default     = "us-east-1"
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
  default     = "0.20.2"
}

variable "otel_demo_chart_version" {
  description = "Opentelemetry Demo Helm Chart release version"
  type        = string
  default     = "0.37.0"
}

variable "honeycomb_storefront_api_key" {
  description = <<-DESC
    (Required) API Key for Honeycomb Storefront.
    Use the environment variable TF_VAR_honeycomb_storefront_api_key if you prefer not to hard-code this value.
  DESC
  type        = string
  sensitive   = true
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

variable "wordpress_password" {
  description = <<-DESC
    (Required) Password for Wordpress admin account.
    Use the environment variable TF_VAR_wordpress_password if you prefer not to hard-code this value.
  DESC
  type        = string
  sensitive   = true
}

variable "wordpress_db_password" {
  description = <<-DESC
    (Required) Password for Wordpress database access.
    Use the environment variable TF_VAR_wordpress_db_password if you prefer not to hard-code this value.
  DESC
  type        = string
  sensitive   = true
}
