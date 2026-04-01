# Project Progress & Notes

## Goal
Build a data agent POC using Gemini Enterprise (30-day trial) + ADK + BigQuery, deployed on Vertex AI Agent Engine, with infrastructure managed via Terraform.

## Architecture
```
Gemini Enterprise (30-day trial, personal GCP account)
    ↓ routes to agent
Vertex AI Agent Engine (hosts the ADK agent)
    ↓ BigQuery API (service account credentials)
BigQuery (public dataset to start)
```

---

## What We've Done

### Project Setup
- [x] Created GCP project: `looker-mcptoolbox` (billing account: `013B75-780189-694A39`)
- [x] Initial Terraform structure with providers, variables, outputs

### Pivots & Decisions
- [x] **Dropped Looker** — too expensive (~$5k+/month for Standard edition). Looker instance resource kept commented out in `looker.tf` as a reference but will not be used.
- [x] **Adopted BigQuery** as the data source instead
- [x] **Gemini Enterprise** — found 30-day free trial available via GCP AI Applications page (personal accounts eligible). This replaces the original Gemini CLI plan.
- [x] **Architecture aligns with** [this article](https://medium.com/google-cloud/power-up-your-adk-agent-building-secure-data-agents-with-gemini-enterprise-vertexai-agent-engine-23020870d3fd), minus the enterprise OAuth/row-level security complexity (not needed for a personal POC — using ADC/service account instead)

### Terraform — Currently Provisioned
- [x] APIs enabled: `bigquery`, `run`, `cloudbuild`, `artifactregistry`, `iam`, `cloudresourcemanager`, `serviceusage`, `looker` (harmless, unused), `discoveryengine` (Gemini Enterprise)
- [x] Service account: `looker-bigquery-sa@looker-mcptoolbox.iam.gserviceaccount.com`
  - Roles: `roles/bigquery.dataViewer`, `roles/bigquery.jobUser`
- [x] Added `discoveryengine.googleapis.com` to `apis.tf` after enabling it via GUI (resolved Terraform drift)

### Key Learnings
- **Terraform drift**: When you enable something via GCP Console/GUI, Terraform doesn't know about it. Fix: add the resource to `.tf` files and run `terraform apply` — for `google_project_service`, if the API is already enabled, Terraform just absorbs it into state without making changes.
- **Gemini Enterprise vs personal GCP**: Gemini Enterprise is normally a Google Workspace add-on, but a 30-day trial is available directly from the GCP AI Applications page on personal accounts.
- **ADC vs OAuth**: The article's OAuth credential-propagation flow is for multi-user enterprise scenarios. For a personal POC, Application Default Credentials (ADC) or a service account is sufficient and much simpler.

---

## Completed

### Terraform Infra Improvements (enterprise best practices)
- [x] Create GCS bucket for remote state: `gs://looker-mcptoolbox-tfstate`
- [x] Migrate `terraform.tfstate` from local to GCS backend (`versions.tf` + `terraform init -migrate-state`)
- [x] Set up Workload Identity Federation — keyless auth between GitHub Actions and GCP via OIDC (no stored keys)
- [x] GitHub Actions workflows:
  - `terraform-plan.yml` — runs `terraform plan` on every PR touching `terraform/**`
  - `terraform-apply.yml` — auto-applies on merge to `main`
- [x] Scoped GitHub Actions SA roles (no broad editor — exact roles only)

### Key Learnings
- **WIF vs OAuth**: WIF uses OIDC (identity/authentication), not OAuth (authorization). GitHub issues a signed JWT per workflow run; GCP verifies it and issues a temporary token. No keys stored anywhere.
- **Terraform drift**: Adding a resource to `.tf` files and running `terraform apply` is sufficient to absorb GUI-created resources into state for `google_project_service`.
- **`terraform.tfvars` not in CI**: Since it's gitignored, vars must be passed explicitly via `-var` flags in workflows.

---

## Up Next (after infra improvements)
- [ ] Add Vertex AI API (`aiplatform.googleapis.com`) to Terraform
- [ ] Add additional IAM roles to service account for Vertex AI Agent Engine
- [ ] Write ADK agent (`agent.py`) that queries BigQuery
- [ ] Deploy agent to Vertex AI Agent Engine
- [ ] Connect Gemini Enterprise to the deployed agent
- [ ] Test end-to-end with a public BigQuery dataset (e.g. `bigquery-public-data.thelook_ecommerce`)
