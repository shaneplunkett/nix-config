---
name: pd-update
description: Gather engineering PD evidence from completed Todoist tasks and format for Confluence update.
allowed-tools: Task, Bash
---

# /pd-update — Engineering PD Evidence Gathering

Gather Shane's engineering professional development evidence and format it for his Confluence PD page.

## Steps

1. **Get PD-labelled completed tasks:**
   Invoke `todoist-ops` via Task agent to filter completed tasks by the `pd-evidence` label. Include task descriptions and any comments for context.

2. **Read current PD page:**
   Invoke `work-ops` via Task agent to read Shane's current Confluence PD page (ID: 697303043) so we know what's already been documented.

3. **Compile evidence:**
   Format the new evidence in a style consistent with the existing page:
   - What was learned/built/achieved
   - Technical skills demonstrated
   - Link to relevant artifacts where possible
   - Date of completion

4. **Deliver for review:**
   Present the compiled evidence to Shane for review before pushing.

5. **Optional — update Confluence:**
   If Shane approves, invoke `work-ops` via Task agent to update the Confluence page directly.

## Tone
Encouraging — this is evidence of growth. Frame it as "look what you've done" not just a dry list. Build that Schema-counter evidence.
