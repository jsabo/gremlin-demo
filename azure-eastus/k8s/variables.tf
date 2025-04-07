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
