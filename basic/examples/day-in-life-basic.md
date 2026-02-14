# Day in the Life (Basic) — Two Scenarios

## Scenario 1: Compaction survival (the problem this kit solves)

User is 90 minutes into a coding session. The agent has been editing files, running tests, and tracking progress.

### What happens without this kit:
- Context hits ~180k tokens. Compaction triggers.
- Agent loses: which file it was editing, what tests passed, what the last error was, what the user's goal was.
- User: "Continue where you left off." Agent: "I'm not sure what we were working on. Could you remind me?"
- User is frustrated. Repeats 20 minutes of context. Cycle repeats.

### What happens with this kit:

**At ~152k tokens** (earlier threshold from recommended config):
- Pre-compaction flush triggers with kit-aware prompt.
- Agent writes to `memory/2026-02-14.md`:
  - Working on: refactoring auth module in `src/auth/handler.ts`
  - Current step: test 4/7 passing, fixing JWT validation
  - Last error: `TypeError: token.split is not a function` line 42
  - Files touched: handler.ts, auth.test.ts, jwt-utils.ts
- Agent updates GLOBAL-STATE.yaml:
  - prediction P3 (refactor auth module): status partial, 4/7 tests passing
  - no new conflicts

**After compaction:**
- Conversation history is summarized. Details lost from context.
- But: GLOBAL-STATE.yaml is on disk. Daily memory log is on disk. Both survive.
- Agent re-reads GLOBAL-STATE.yaml and `memory/2026-02-14.md`.
- Agent: "Picking up where we left off — we're refactoring the auth module, 4/7 tests passing, last issue was a TypeError on line 42 of handler.ts. Let me look at that."
- Session continues without the user repeating anything.

### What happens when the flush fails:
- Flush is skipped (sandbox has read-only workspace, or compaction fires between turns).
- Agent finds itself mid-conversation with vague context. Triggers recovery protocol.
- Step 1: reads GLOBAL-STATE.yaml → finds prediction P3 for auth refactor, status "in_progress."
- Step 2: reads `memory/2026-02-14.md` → finds earlier entry from the proactive working state save (written 20 minutes ago during the session): "refactoring auth module, 2/7 tests passing, working on JWT validation."
- Step 3: runs `memory_search("auth handler refactor JWT")` → finds additional context from a prior session about the JWT library choice.
- Step 4: announces to user: "I recovered most of my context. We're refactoring the auth module — my last saved state was 2/7 tests passing on JWT validation. I may have made more progress since then. Can you confirm where we are?"
- Recovery is partial but functional. The user fills in one detail instead of repeating 20 minutes of work.


## Scenario 2: Decision conflict detection

User request: "Add a goal to automate vendor outreach for Q2."

### 1) Classify and predict
Action classification: **Structural** (modifying GLOBAL-STATE.yaml).

Level 2 prediction recorded:
- id: P1, action: "Add vendor outreach goal", expected: "clean state update", risk: low

### 2) Act
- Added goal G2: "Automate Q2 vendor outreach"
- Updated `last_update`

### 3) Postflight: conflict detected
Existing constraint K1: "Ask before external or public actions"
Vendor outreach requires sending external emails → conflicts with K1.

### 4) Log conflict, apply policy
Conflict X1 logged in GLOBAL-STATE.yaml:
- title: "Vendor outreach conflicts with external action constraint"
- execution_policy: analysis_allowed_execution_blocked
- status: open

### 5) Report to user
- Goal added. Conflict detected: vendor outreach requires external communication, which is constrained.
- Analysis and planning can proceed. Sending emails is blocked pending your decision.
- Options: relax the constraint for vendor outreach, or approve each outreach individually.
