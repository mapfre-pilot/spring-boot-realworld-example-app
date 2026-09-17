# Appian Dev MCP launcher

`run-appian-mcp.sh` starts the [Appian Dev MCP](https://docs.appian.com/suite/help/26.6/devmcp.html)
server over STDIO. On first run it downloads the server bundle from the Appian site
(`/suite/plugins/servlet/stateless/dev-mcp-bundle`) and installs dependencies with `uv`;
later runs start immediately.

Requirements: `bash`, `curl`, `tar`. `uv` and Python 3.13 are installed automatically if missing.

## Environment variables

| Variable | Description |
| --- | --- |
| `LCP_URL` | Appian site (default `https://mapfrespain-test.appiancloud.com`) |
| `USERNAME` / `PASSWORD` | Appian designer credentials (basic auth). `APPIAN_USERNAME` / `APPIAN_PASSWORD` are used as fallback |
| `LCP_TOOL_MODE` | `full` (default) or `readonly` |
| `APPIAN_MCP_HOME` | Install directory (default `~/appian-dev-mcp-server`) |

## MCP client configuration

```json
{
  "mcpServers": {
    "appian": {
      "command": "bash",
      "args": ["/path/to/tools/appian-mcp/run-appian-mcp.sh"],
      "env": {
        "LCP_URL": "https://mapfrespain-test.appiancloud.com",
        "USERNAME": "user",
        "PASSWORD": "secret"
      }
    }
  }
}
```
