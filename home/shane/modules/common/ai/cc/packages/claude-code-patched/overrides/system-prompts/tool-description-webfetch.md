<!--
name: 'Tool Description: WebFetch'
description: WebFetch disabled — route all web reads through `bb fetch` via Bash
ccVersion: 2.1.123
-->
WebFetch is disabled in this environment. The harness will deny every call.

For any web read — static page, article, doc, JS-rendered site, anything — use `bb fetch <url>` via Bash. Returns raw markdown direct to stdout, no inner-model summarisation step (so no 125-char quote ceiling, no paraphrase-mangling).

- `bb fetch <url>` — default; follow redirects with `--allow-redirects`, route through residential IPs with `--proxies`.
- `bb search "<query>"` — structured web search.
- Fetch independent URLs in parallel — one message, multiple Bash calls.

Pipe straight to a file when the user wants a verbatim save: `bb fetch <url> > path/to/file.md`. No Write tool needed in that path.
