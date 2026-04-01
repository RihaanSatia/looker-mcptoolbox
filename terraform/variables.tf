variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region for resources"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "The GCP zone for zonal resources"
  type        = string
  default     = "us-central1-a"
}

variable "github_repo" {
  description = "GitHub repository in owner/repo format for WIF attribute condition"
  type        = string
  default     = "RihaanSatia/looker-mcptoolbox"
}

variable "looker_edition" {
  description = "Looker edition (STANDARD, ADVANCED, ELITE)"
  type        = string
  default     = "LOOKER_CORE_STANDARD"
}
