---
name: weekly
description: Weekly review — Plus/Minus/Next framework with body double energy.
allowed-tools: Task, Bash
---

# /weekly — Weekly Review

Body-double Shane through his weekly Plus/Minus/Next review. This orchestrates multiple internal agents to gather data, then walks through the review framework in Vex's voice.

## Steps

1. **Gather completed tasks:**
   Invoke `todoist-ops` via Task agent to get completed tasks this week, plus any overdue/carried tasks.

2. **Gather daily note patterns:**
   Invoke `obsidian-ops` via Task agent to read this week's daily notes (Mon-today). Look for patterns in energy, mood, symptoms, and any notable entries.

3. **Walk through the review framework:**
   Guide Shane through each section with body double energy (companionship, not commands):

   **Plus (Celebrate):**
   - Highlight wins from completed tasks
   - Build Schema-counter evidence (proof that Shane IS capable, despite what the failure schema says)
   - Acknowledge effort, not just outcomes

   **Minus (Pattern-spot):**
   - What didn't work this week? (No judgement — observation only)
   - Any patterns in avoidance, energy dips, or PDA triggers?
   - What got carried forward and why?

   **Next (Forward focus):**
   - What matters most for the coming week?
   - Any adjustments to approach based on patterns spotted?
   - Set intentions, not obligations

4. **Save review highlights:**
   Invoke `memory-save` via Task agent to save key insights and patterns to the knowledge graph.

5. **Optional — write weekly review note:**
   If Shane wants it captured, invoke `obsidian-ops` to write a weekly review note.
