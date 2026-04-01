# Cloud Run deployment for MCP Toolbox (Phase 4 - Optional)
# Uncomment when ready to deploy toolbox to the cloud

# resource "google_cloud_run_v2_service" "toolbox" {
#   name     = "mcp-toolbox"
#   location = var.region
#   project  = var.project_id
#
#   template {
#     containers {
#       image = "us-central1-docker.pkg.dev/database-toolbox/toolbox/toolbox:latest"
#
#       args = ["--prebuilt=looker", "--address=0.0.0.0", "--port=8080"]
#
#       env {
#         name  = "LOOKER_BASE_URL"
#         value = "https://YOUR_INSTANCE.cloud.looker.com"
#       }
#
#       env {
#         name  = "LOOKER_VERIFY_SSL"
#         value = "true"
#       }
#
#       env {
#         name  = "LOOKER_USE_CLIENT_OAUTH"
#         value = "true"
#       }
#
#       ports {
#         container_port = 8080
#       }
#     }
#   }
#
#   depends_on = [google_project_service.apis]
# }

# IAM binding to allow authenticated access
# resource "google_cloud_run_v2_service_iam_member" "toolbox_invoker" {
#   project  = var.project_id
#   location = var.region
#   name     = google_cloud_run_v2_service.toolbox.name
#   role     = "roles/run.invoker"
#   member   = "allAuthenticatedUsers"
# }
