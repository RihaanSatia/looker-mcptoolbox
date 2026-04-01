# Looker Instance
# WARNING: Looker instances are expensive (~$5,000+/month for Standard edition)
# Uncomment when ready to deploy, and destroy promptly after testing

# resource "google_looker_instance" "main" {
#   name     = "looker-mcp-instance"
#   project  = var.project_id
#   region   = var.region
#
#   platform_edition = var.looker_edition
#
#   oauth_config {
#     client_id     = var.looker_oauth_client_id
#     client_secret = var.looker_oauth_client_secret
#   }
#
#   # Public IP for easier access (use private for production)
#   public_ip_enabled = true
#
#   depends_on = [google_project_service.apis]
# }

# Uncomment these variables in variables.tf when enabling Looker:
#
# variable "looker_oauth_client_id" {
#   description = "OAuth client ID for Looker instance"
#   type        = string
#   sensitive   = true
# }
#
# variable "looker_oauth_client_secret" {
#   description = "OAuth client secret for Looker instance"
#   type        = string
#   sensitive   = true
# }
