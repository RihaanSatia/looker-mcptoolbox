import os

import google.auth.transport.requests
import google.oauth2.id_token
from google.adk.agents import Agent
from google.adk.tools.mcp_tool import McpToolset
from google.adk.tools.mcp_tool.mcp_session_manager import StreamableHTTPConnectionParams

MCP_TOOLBOX_URL = os.environ.get(
    "MCP_TOOLBOX_URL",
    "https://toolbox-742007288305.us-central1.run.app/mcp",
)

# Audience for Cloud Run IAM identity token is the base service URL (no path)
_AUDIENCE = "https://toolbox-742007288305.us-central1.run.app"


def _get_identity_token() -> str:
    auth_req = google.auth.transport.requests.Request()
    return google.oauth2.id_token.fetch_id_token(auth_req, _AUDIENCE)


root_agent = Agent(
    model="gemini-3.1-pro-preview",
    name="bq_data_agent",
    instruction="""You are a data analyst assistant with access to BigQuery via the MCP Toolbox.

The primary dataset available is bigquery-public-data.thelook_ecommerce, which contains
e-commerce data: orders, order_items, products, users, inventory_items, distribution_centers.

Guidelines:
- Use search_catalog or list_table_ids to explore available tables when needed
- Use get_table_info to understand schemas before writing queries
- Use execute_sql to run SQL — always use fully qualified table names:
  `bigquery-public-data.thelook_ecommerce.<table_name>`
- Use ask_data_insights for complex analytical questions about specific tables
- Use forecast for time series predictions
- Present results clearly with a brief explanation of what the data shows
- If a query returns a lot of rows, summarise the key findings rather than listing everything
""",
    tools=[
        McpToolset(
            connection_params=StreamableHTTPConnectionParams(
                url=MCP_TOOLBOX_URL,
                headers={"Authorization": f"Bearer {_get_identity_token()}"},
            )
        )
    ],
)
