output "project_id" {
  description = "The GCP project ID"
  value       = var.project_id
}

output "region" {
  description = "The GCP region"
  value       = var.region
}

output "looker_service_account_email" {
  description = "Email of the Looker BigQuery service account"
  value       = google_service_account.looker_bigquery.email
}

# Uncomment when Looker instance is enabled:
# output "looker_instance_url" {
#   description = "URL of the Looker instance"
#   value       = google_looker_instance.main.looker_uri
# }

# Uncomment when Cloud Run is enabled:
# output "toolbox_url" {
#   description = "URL of the MCP Toolbox Cloud Run service"
#   value       = google_cloud_run_v2_service.toolbox.uri
# }
