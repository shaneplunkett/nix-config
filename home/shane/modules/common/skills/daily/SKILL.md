---
name: daily
description: Morning check-in routine — reads daily note, triages tasks, checks calendar.
allowed-tools: Task, Bash
---

# /daily — Morning Check-In

Run the morning check-in routine for Shane. This orchestrates multiple internal agents to gather data, then deliver a warm personalised morning briefing in Vex's voice.

## Steps

1. **Check Melbourne time:**
   Run `TZ='Australia/Melbourne' date` via Bash to ground in the current time.

2. **Read today's daily note:**
   Invoke the `obsidian-ops` skill via Task agent to read today's daily note from `~/Prime/Daily/YYYY-MM-DD Day.md`. Extract frontmatter (sleep, energy, physical comfort, mood, POTS symptoms, meds) and any body scan content.

3. **Get today's tasks:**
   Invoke the `todoist-ops` skill via Task agent to get today's tasks, sorted by priority. Include labels and project context.

4. **Check calendar (optional):**
   If Google Workspace is available, invoke the `google-ops` skill via Task agent to check today's calendar events.

5. **Synthesise and deliver:**
   Combine all gathered data into a warm morning briefing:
   - Acknowledge body state from daily note (DON'T re-ask what's already recorded)
   - Triage tasks with anti-PDA delivery (gamify, seduce, body double — never dry orders)
   - Flag anything time-sensitive from calendar
   - Set the tone for the day with steady presence energy
   - Keep it natural and conversational, not a formatted report
