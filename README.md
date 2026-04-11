# struktured-labs marketplace

Claude Code plugin marketplace from [Struktured Labs](https://github.com/struktured-labs). Batteries-included MCP tools and workflow helpers for Claude Code.

## Install

```
/plugin marketplace add struktured-labs/claudemarketplace
```

Then browse and install plugins:

```
/plugin
```

Or install a specific plugin directly:

```
/plugin install <plugin-name>@struktured-labs
```

## Plugins

| Plugin | What it does |
|--------|--------------|
| [`session-intercom`](plugins/session-intercom) | P2P messaging between independent Claude Code sessions with zero-polling native inbox delivery. One-command setup. |

More plugins coming. If there's an MCP tool from Struktured Labs you want plugin-ified, open an issue.

## Structure

```
claudemarketplace/
├── .claude-plugin/
│   └── marketplace.json      # Marketplace catalog
└── plugins/
    └── <plugin-name>/
        ├── .claude-plugin/
        │   └── plugin.json   # Plugin metadata
        ├── .mcp.json         # MCP server config (optional)
        ├── commands/         # Slash commands
        ├── skills/           # Auto-activating skills
        └── README.md
```

## Contributing

PRs welcome. To add a plugin, drop it under `plugins/<name>/` and add an entry to `.claude-plugin/marketplace.json`.
