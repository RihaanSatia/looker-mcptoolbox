# Looker MCP + Gemini CLI — Personal GCP Setup

## Goal
Set up the Looker MCP Toolbox locally, connect it to a personal Looker instance, and test dashboard creation via Gemini CLI. This is a learning exercise to understand the end-to-end flow.

## Prerequisites
- Personal GCP account with billing enabled
- gcloud CLI installed and authenticated
- Node.js installed (for npx)
- Gemini CLI installed (https://github.com/google-gemini/gemini-cli)
- A Looker instance (free trial or existing) — if you don't have one, create a Looker (Google Cloud core) instance in your GCP project

## Architecture
```
Gemini CLI (terminal)
    ↓ prompt
MCP Toolbox (local binary, localhost:5000)
    ↓ Looker API calls
Looker instance (your-instance.cloud.looker.com)
    ↓ SQL
BigQuery (your dataset)
```

## Phase 1: Set Up Looker Instance

1. Enable the Looker API in your GCP project:
   ```bash
   gcloud services enable looker.googleapis.com
   ```

2. If you don't have a Looker instance, create one via Console:
   - Go to Looker in GCP Console
   - Create instance (standard edition, public secure connections is simplest)
   - Region: pick closest to you
   - Set up OAuth client in APIs & Services > Credentials (Web application type)
   - Note: instance creation takes ~30-60 minutes

3. Once the instance is up, log in via the instance URL and create a simple LookML project:
   - Connect to a BigQuery dataset (can use public datasets like `bigquery-public-data.thelook_ecommerce`)
   - Generate a basic model from the connection
   - Validate and deploy to production

## Phase 2: Get Looker API Credentials

### Option A: Client ID + Secret (simpler, start here)
1. In your Looker instance, go to Admin > Users > your user
2. Under API Keys (API3 Keys), click New API Key
3. Save the Client ID and Client Secret

### Option B: OAuth (test after Option A works)
1. In Looker API Explorer, find `register_oauth_client_app` under Auth
2. Register with:
   - client_guid: `gemini-cli`
   - redirect_uri: `http://localhost:7777/oauth/callback`
   - display_name: `Gemini CLI`
   - description: `Local Gemini CLI access`
   - enabled: true

## Phase 3: Install and Run MCP Toolbox

### For Client ID + Secret (Option A):
1. Download the toolbox binary:
   ```bash
   # macOS ARM
   curl -O https://storage.googleapis.com/genai-toolbox/v0.30.0/darwin/arm64/toolbox
   # macOS Intel
   curl -O https://storage.googleapis.com/genai-toolbox/v0.30.0/darwin/amd64/toolbox
   # Linux
   curl -O https://storage.googleapis.com/genai-toolbox/v0.30.0/linux/amd64/toolbox
   chmod +x toolbox
   ```

2. Set environment variables:
   ```bash
   export LOOKER_BASE_URL="https://your-instance.cloud.looker.com"
   export LOOKER_CLIENT_ID="your-client-id"
   export LOOKER_CLIENT_SECRET="your-client-secret"
   export LOOKER_VERIFY_SSL="true"
   ```

3. Run the toolbox:
   ```bash
   ./toolbox --prebuilt looker
   ```
   Should start listening on localhost:5000.

### For OAuth (Option B):
1. Set environment variables (no client ID/secret needed):
   ```bash
   export LOOKER_BASE_URL="https://your-instance.cloud.looker.com"
   export LOOKER_VERIFY_SSL="true"
   export LOOKER_USE_CLIENT_OAUTH="true"
   ```

2. Run the toolbox:
   ```bash
   ./toolbox --prebuilt looker
   ```

## Phase 4: Configure Gemini CLI

### For Client ID + Secret (Option A):
Edit `~/.gemini/settings.json`:
```json
{
  "mcpServers": {
    "looker": {
      "httpUrl": "http://localhost:5000/mcp"
    }
  }
}
```

### For OAuth (Option B):
Edit `~/.gemini/settings.json`:
```json
{
  "mcpServers": {
    "looker": {
      "httpUrl": "http://localhost:5000/mcp",
      "oauth": {
        "enabled": true,
        "clientId": "gemini-cli",
        "authorizationUrl": "https://your-instance.cloud.looker.com/auth",
        "tokenUrl": "https://your-instance.cloud.looker.com/api/token",
        "scopes": ["cors_api"]
      }
    }
  }
}
```

## Phase 5: Test

1. Start Gemini CLI:
   ```bash
   gemini
   ```

2. If using OAuth, authenticate:
   ```
   /mcp auth looker
   ```
   Browser opens, sign in, consent, done.

3. Verify connection:
   ```
   /mcp
   ```
   Should show looker server as Ready with available tools.

4. Test queries:
   - "List all models"
   - "Show me the explores in the thelook model"
   - "Query the order_items explore and show me total revenue by category"
   - "Create a dashboard showing monthly revenue trend"

## Phase 6: Deploy Toolbox to Cloud Run (optional, simulates enterprise)

If you want to test the server-side deployment:

1. Enable APIs:
   ```bash
   gcloud services enable run.googleapis.com cloudbuild.googleapis.com artifactregistry.googleapis.com
   ```

2. Deploy:
   ```bash
   export IMAGE=us-central1-docker.pkg.dev/database-toolbox/toolbox/toolbox:latest

   gcloud run deploy toolbox \
     --image $IMAGE \
     --region us-central1 \
     --env-vars LOOKER_BASE_URL="https://your-instance.cloud.looker.com",LOOKER_VERIFY_SSL="true",LOOKER_USE_CLIENT_OAUTH="true" \
     --args="--prebuilt=looker","--address=0.0.0.0","--port=8080" \
     --no-allow-unauthenticated
   ```

3. Update `~/.gemini/settings.json` to point `httpUrl` to the Cloud Run URL instead of localhost.

## Key References
- MCP Toolbox Looker source config: https://googleapis.github.io/genai-toolbox/resources/sources/looker/
- MCP Toolbox Looker tools: https://googleapis.github.io/genai-toolbox/resources/tools/looker/
- Gemini CLI OAuth sample: https://googleapis.github.io/genai-toolbox/samples/looker/looker_gemini_oauth/
- Looker OAuth registration: https://docs.cloud.google.com/looker/docs/api-cors
- Google guide (Gemini Enterprise + ADK): https://cloud.google.com/blog/products/business-intelligence/connecting-looker-to-gemini-enterprise-with-mcp-toolbox-and-adk

## Troubleshooting
- If toolbox can't reach Looker: check the base URL, try adding :19999 port
- If OAuth redirect fails: verify redirect_uri in registration matches exactly
- If "no models found": check that your LookML project is deployed to production mode
- If tools show but queries fail: verify your user has explore/query permissions in Looker