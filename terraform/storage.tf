# GCS bucket for Vertex AI Agent Engine staging
resource "google_storage_bucket" "agent_staging" {
  name          = "looker-mcptoolbox-agent-staging"
  project       = var.project_id
  location      = var.region
  force_destroy = true

  uniform_bucket_level_access = true

  depends_on = [google_project_service.apis]
}
