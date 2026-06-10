---
name: implement-ralph-loop
description: "Implement a spec from the specs directory using Ralph Loop agent execution in tmux. Creates branches, updates PRD, and launches autonomous agent loops. Use when the user wants to execute a spec file, run Ralph, implement specs with agents (qwen, codex, opencode, gemini), or launch automated implementation. Triggers on: implement spec, run ralph, execute spec, ralph loop, auto-implement, agent loop. Always use when a spec file path is mentioned with intent to implement."
---

# Implement Ralph Loop

Implement a spec from the specs directory and run Ralph Loop in a tmux window to process it. This command updates the PRD with the new spec, creates an appropriate branch, and launches Ralph to execute the implementation.

## Instructions

### Phase 1: Parse Arguments

1. **Parse Arguments:**
   - If `$ARGUMENTS` is empty or not provided:
     - Ask: "Which spec file would you like me to implement? (e.g., specs/020-run-ralph-in-tmux-chore.md)"
     - Wait for user to provide the spec file
   - If `$ARGUMENTS` is provided, parse it:
     - First argument: spec file path (required)
     - Second argument: agent name (optional, defaults to 'qwen') - one of: qwen, codex, opencode, gemini
     - Example: `specs/020-run-ralph-in-tmux-chore.md codex`
     - Example: `specs/020-run-ralph-in-tmux-chore.md` (uses qwen agent)

2. **Determine Target Session:**
   - Always detect active tmux session with: `tmux display-message -p '#S' 2>/dev/null`
   - If in tmux (command succeeds):
     - Use the returned session name as `{target-session}`
     - Show: "Using current session: {target-session}"
   - If not in tmux (command fails):
     - Use the current directory name as session name
     - Show: "Will create/use session: {target-session}"

3. **Determine Agent:**
   - If second argument provided and is one of: qwen, codex, opencode, gemini
     - Use that agent
   - Otherwise default to 'qwen'
   - Store in variable: `{agent}`
   - Show: "Agent: {agent}"

4. **Validate Spec File:**
   - Check if the provided spec file exists
   - Verify the file is in the `specs/` directory
   - If file doesn't exist, show error and ask for correct path
   - Read the spec file to understand what needs to be implemented

### Phase 2: Extract Spec Information

5. **Parse Spec File:**
   - Extract the spec ID (number from filename, e.g., "020" from "specs/020-run-ralph-in-tmux-chore.md")
   - Extract the spec title/description
   - Extract the spec type (feature, bug, chore, etc.)
   - Extract the user story ID if present (e.g., "US-044")

6. **Generate Branch Name:**
   - Format: `ralph/{spec-number}-{spec-type}-{short-description}`
   - Example: `ralph/020-chore-run-ralph-in-tmux`
   - Convert to lowercase, replace spaces with hyphens, max 50 characters

### Phase 3: Update PRD

7. **Backup Current PRD:**
   - Copy `prd.json` to `prd.backup.json`
   - Show confirmation message: "Backed up current PRD to prd.backup.json"

8. **Update prd.json:**
   - Read the current `prd.json` (in project root)
   - Update `branchName` field with the new branch name
   - Check if spec contains a user story (US-XXX):
     - If yes, find and update that user story's `passes` field to `false`
     - If no, append a new user story to the `userStories` array with:
       - `id`: Extracted from spec or auto-generated
       - `title`: Spec title
       - `description`: Full spec description
       - `acceptanceCriteria`: Extracted from spec or default to ["Implement the spec"]
       - `priority`: Next available priority number
       - `passes`: false
       - `notes`: "Created from {spec filename}"
   - Write the updated PRD back to `prd.json` (in project root)
   - Show confirmation: "Updated PRD with new spec and branch name"

### Phase 4: Create Git Branch

9. **Checkout/Create Branch:**
   - Run `git checkout -b {branch-name}`
   - If branch already exists:
     - Ask: "Branch {branch-name} already exists. Continue with existing branch or create new? (existing/new)"
     - If "existing": run `git checkout {branch-name}`
     - If "new": generate new branch name with timestamp
   - Show confirmation: "Checked out branch: {branch-name}"

### Phase 5: Verify tmux Session

10. **Check for Target Session:**
    - Run `tmux list-sessions` to check if '{target-session}' session exists
    - If session doesn't exist:
      - Create it with `tmux new-session -d -s {target-session}`
      - Show: "Created tmux session: {target-session}"
    - If session exists, show: "Using existing tmux session: {target-session}"

11. **Check for Existing ralph Window:**
    - Run `tmux list-windows -t {target-session}` to see current windows
    - Check if a window named "ralph" already exists
    - If ralph window exists:
      - Ask: "A 'ralph' window already exists in session '{target-session}'. Kill it and create new? (yes/no)"
      - If yes: run `tmux kill-window -t {target-session}:ralph`
      - If no: exit with message "Please close the existing ralph window first"

### Phase 6: Launch Ralph in tmux

12. **Create New Window for Ralph:**
    - Run `tmux new-window -t {target-session} -n ralph`
    - Show: "Created new tmux window: ralph in session: {target-session}"

13. **Navigate to Project Directory:**
    - Use the current working directory (where Claude Code is running)
    - Send command: `tmux send-keys -t {target-session}:ralph 'cd {project-root}' Enter`
    - Show: "Set working directory in ralph window"

14. **Start Ralph Loop:**
    - Send command: `tmux send-keys -t {target-session}:ralph 'cd scripts/ralph && bash ralph.sh {agent} 10' Enter`
    - Show: "Started Ralph Loop with {agent} agent in ralph window"
    - Show: "Monitor progress: tmux attach -t {target-session}:ralph"
    - Show: "Detach: Ctrl+B then D"
    - Show: "Kill Ralph: tmux kill-window -t {target-session}:ralph"

### Phase 7: Verification

15. **Verify Ralph is Running:**
    - Wait 3 seconds
    - Run `tmux capture-pane -t {target-session}:ralph -p | head -20`
    - Show the output to verify Ralph started successfully
    - Check for "Starting Ralph" message in output

16. **Final Summary:**
    - Show summary of what was done:
      - Spec file loaded
      - Branch created
      - PRD updated
      - Agent: {agent}
      - Ralph launched in session: {target-session}
    - Show current PRD user story status

## Examples

- `/implement-ralph-loop` - Interactive mode, asks for spec file
- `/implement-ralph-loop "specs/020-run-ralph-in-tmux-chore.md"` - Implements spec 020 with qwen agent in current session
- `/implement-ralph-loop "specs/021-add-user-auth-feature.md" codex` - Implements spec 021 with codex agent
- `/implement-ralph-loop "specs/022-some-chore.md" gemini` - Implements spec 022 with gemini agent
- `/implement-ralph-loop "specs/023-feature.md" opencode` - Implements spec 023 with opencode agent

## Notes

**Security:**
- Always backup PRD before modifying
- Validate spec file path to prevent directory traversal
- Never overwrite prd.json without creating backup

**Prerequisites:**
- tmux must be installed
- Spec files must exist in `specs/` directory
- `prd.json` must exist in project root
- `scripts/ralph/ralph.sh` must be executable

**Ralph Loop Behavior:**
- Ralph runs continuously until all user stories are complete
- Monitor progress in `scripts/ralph/progress.txt`
- Ralph archives previous runs when branch changes
- Available agents: qwen (default), codex, opencode, gemini
- Default: 10 iterations per run
- Ralph can take several minutes to hours depending on stories
- Completion signal: `RALPH_COMPLETE_ALL_TASKS`

**Troubleshooting:**
- If tmux session doesn't exist, command will create it automatically
- If ralph window already exists, command will ask before killing it
- Check `scripts/ralph/progress.txt` for Ralph's current progress
- Attach to ralph window to see real-time output: `tmux attach -t {session-name}:ralph`
- Detach from window: Press `Ctrl+B` then `D`
- To see which tmux sessions are available: `tmux list-sessions`
- Session defaults to the current active tmux session

**Branch Naming:**
- Branch names are auto-generated from spec filename
- Format: `ralph/{number}-{type}-{description}`
- Branch names are lowercase with hyphens
- Max length: 50 characters

**Common Issues:**
- If spec file not found: Check path is correct and in `specs/` directory
- If PRD backup fails: Check write permissions on project root
- If branch creation fails: Check git status and commit/stash changes
- If tmux fails: Install tmux with `sudo apt-get install tmux` (Linux) or `brew install tmux` (Mac)
