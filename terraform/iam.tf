# Service account for Looker to access BigQuery
resource "google_service_account" "looker_bigquery" {
  account_id   = "looker-bigquery-sa"
  display_name = "Looker BigQuery Service Account"
  description  = "Service account for Looker to query BigQuery datasets"
  project      = var.project_id

  depends_on = [google_project_service.apis]
}

# Grant BigQuery Data Viewer role to the service account
resource "google_project_iam_member" "looker_bigquery_viewer" {
  project = var.project_id
  role    = "roles/bigquery.dataViewer"
  member  = "serviceAccount:${google_service_account.looker_bigquery.email}"
}

# Grant BigQuery Job User role (required to run queries)
resource "google_project_iam_member" "looker_bigquery_job_user" {
  project = var.project_id
  role    = "roles/bigquery.jobUser"
  member  = "serviceAccount:${google_service_account.looker_bigquery.email}"
}
