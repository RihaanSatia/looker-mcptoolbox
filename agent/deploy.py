"""
Deploy the BQ data agent to Vertex AI Agent Engine.

Prerequisites:
  1. Create a staging bucket:
       gsutil mb -p looker-mcptoolbox -l us-central1 gs://looker-mcptoolbox-agent-staging
  2. Install dependencies locally:
       pip install -r requirements.txt
  3. Authenticate:
       gcloud auth application-default login

Run:
  python deploy.py
"""

import vertexai
from vertexai.preview import reasoning_engines
from vertexai import agent_engines

PROJECT_ID = "looker-mcptoolbox"
LOCATION = "us-central1"
STAGING_BUCKET = "gs://looker-mcptoolbox-agent-staging"

vertexai.init(project=PROJECT_ID, location=LOCATION, staging_bucket=STAGING_BUCKET)

from agent.agent import root_agent  # noqa: E402 — must init vertexai first

adk_app = reasoning_engines.AdkApp(
    agent=root_agent,
    enable_tracing=False,
)

print("Deploying agent to Vertex AI Agent Engine (this takes ~5-10 minutes)...")

remote_app = agent_engines.create(
    agent_engine=adk_app,
    extra_packages=["./agent"],
    requirements=[
        "google-cloud-aiplatform[adk,agent_engines]",
        "google-auth",
        "mcp",
    ],
)

print(f"\nDeployment complete.")
print(f"Resource name: {remote_app.resource_name}")
print(f"\nSave this resource name — you will need it to register the agent with Gemini Enterprise.")
