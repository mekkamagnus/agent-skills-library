# tmux Terminal Multiplexer Documentation

## Overview

**tmux** is a terminal multiplexer that lets you switch easily between several programs in one terminal, detach them (they keep running in the background) and reattach them to a different terminal.

**Usage:**
```bash
tmux [-2CDlNuVv] [-c shell-command] [-f file] [-L socket-name] [-S socket-path] [-T features] [command [flags]]
```

### Flags
| Flag | Description |
|------|-------------|
| `-2` | Force tmux to assume the terminal supports 256 colours |
| `-C` | Start in control mode (used for integrated terminal applications) |
| `-D` | Do not start the tmux server as a daemon |
| `-l` | Behave as a login shell |
| `-N` | Do not start the server |
| `-u` | Force UTF-8 mode |
| `-v` | Request verbose logging |
| `-V` | Show version |
| `-c shell-command` | Execute shell-command using default shell |
| `-f file` | Specify an alternative configuration file |
| `-L socket-name` | Specify server socket name |
| `-S socket-path` | Specify server socket path |

---

## Core Concepts

### Hierarchy
tmux organizes terminals into a three-level hierarchy:

```
Session (top level)
 └── Window (second level)
     └── Pane (bottom level)
```

- **Session**: A collection of windows, can be attached/detached
- **Window**: Equivalent to a tab, contains one or more panes
- **Pane**: A virtual terminal within a window

---

## Session Management

### Create New Session

```bash
# Create session with default name
tmux new-session

# Create named session
tmux new-session -s mysession

# Create session with specific window name
tmux new-session -s mysession -n "my-window"

# Create session with window size
tmux new-session -s mysession -x 120 -y 40

# Create session in specific directory
tmux new-session -s mysession -c /path/to/dir

# Create session with specific command
tmux new-session -s mysession "vim main.go"

# Create session and don't attach
tmux new-session -d -s mysession
```

### Attach to Session

```bash
# Attach to last session
tmux attach-session
tmux attach

# Attach to named session
tmux attach-session -t mysession
tmux attach -t mysession

# Attach to session and change working directory
tmux attach -t mysession -c /new/path

# Detach other clients from session
tmux attach -d -t mysession
```

### List Sessions

```bash
# List all sessions
tmux list-sessions

# List with custom format
tmux list-sessions -F "#{session_name}: #{session_windows} windows"

# List sessions with creation time
tmux list-sessions -F "#{session_name} (created: #{session_created_string})"

# Filter sessions
tmux list-sessions -f "#{m:*dev*,#{session_name}}"
```

### Session Format Variables
| Variable | Description |
|----------|-------------|
| `#{session_name}` | Session name |
| `#{session_windows}` | Number of windows |
| `#{session_id}` | Unique session ID |
| `#{session_created}` | Creation timestamp |
| `#{session_created_string}` | Formatted creation time |
| `#{session_attached}` | Number of attached clients |

### Kill Sessions

```bash
# Kill specific session
tmux kill-session -t mysession

# Kill all sessions except current
tmux kill-session -a

# Kill all sessions
tmux kill-server
```

### Rename Session

```bash
tmux rename-session -t oldname newname
```

---

## Window Management

### Create New Windows

```bash
# Create window in specific session
tmux new-window -t mysession

# Create named window
tmux new-window -t mysession -n "editor"

# Create window with starting directory
tmux new-window -c /path/to/dir

# Create window with command
tmux new-window "htop"

# Create window in background
tmux new-window -d

# Create window at specific index
tmux new-window -t mysession:2
```

### List Windows

```bash
# List all windows
tmux list-windows

# List windows in specific session
tmux list-windows -t mysession

# List with custom format
tmux list-windows -t mysession -F "#{window_index}: #{window_name} (#{window_width}x#{window_height})"

# List all windows across sessions
tmux list-windows -a
```

### Window Format Variables
| Variable | Description |
|----------|-------------|
| `#{window_index}` | Window index (number) |
| `#{window_name}` | Window name |
| `#{window_id}` | Unique window ID |
| `#{window_width}` | Window width in characters |
| `#{window_height}` | Window height in characters |
| `#{window_layout}` | Window layout string |
| `#{window_active}` | 1 if active, 0 otherwise |
| `#{window_flags}` | Flags (e.g., *, -, Z) |

### Switch Between Windows

```bash
# Select window by index
tmux select-window -t mysession:2

# Select window by name
tmux select-window -t mysession:editor

# Next window
tmux next-window

# Previous window
tmux previous-window

# Last window
tmux last-window
```

### Rename Window

```bash
tmux rename-window -t mysession:1 "new-name"
```

### Move Window

```bash
# Move window to different index
tmux move-window -s 1 -t 5

# Move window to different session
tmux move-window -s src_session:window -t dst_session
```

### Kill Window

```bash
# Kill specific window
tmux kill-window -t mysession:1

# Kill all windows except current
tmux kill-window -a
```

---

## Pane Management

### Split Windows

```bash
# Split vertically (top/bottom)
tmux split-window -t mysession:1

# Split horizontally (left/right)
tmux split-window -h -t mysession:1

# Split with specific size (percentage)
tmux split-window -l 30% -t mysession:1

# Split with starting directory
tmux split-window -c /path/to/dir

# Split with command
tmux split-window "npm run dev"

# Split and don't focus new pane
tmux split-window -b
```

### List Panes

```bash
# List panes in current window
tmux list-panes

# List panes in specific window
tmux list-panes -t mysession:1

# List all panes in session
tmux list-panes -s -t mysession

# List with custom format
tmux list-panes -F "#{pane_index}: #{pane_current_command} [#{pane_current_path}]"
```

### Pane Format Variables
| Variable | Description |
|----------|-------------|
| `#{pane_index}` | Pane index within window |
| `#{pane_id}` | Unique pane ID (e.g., %1) |
| `#{pane_current_command}` | Current command running |
| `#{pane_current_path}` | Current working directory |
| `#{pane_pid}` | PID of foreground process |
| `#{pane_width}` | Pane width |
| `#{pane_height}` | Pane height |
| `#{pane_active}` | 1 if active, 0 otherwise |

### Select Panes

```bash
# Select pane by index
tmux select-pane -t 1

# Select pane by ID
tmux select-pane -t %1

# Select pane directionally
tmux select-pane -L  # left
tmux select-pane -R  # right
tmux select-pane -U  # up
tmux select-pane -D  # down

# Select last pane
tmux last-pane
```

### Resize Panes

```bash
# Resize by adjustment
tmux resize-pane -U 10  # up 10 cells
tmux resize-pane -D 5   # down 5 cells
tmux resize-pane -L 5   # left 5 cells
tmux resize-pane -R 10  # right 10 cells

# Resize to specific dimensions
tmux resize-pane -x 80 -y 24
```

### Kill Pane

```bash
# Kill specific pane
tmux kill-pane -t %1

# Kill all panes except current
tmux kill-pane -a
```

---

## Send Keys - Automated Input

### Basic Send Keys

```bash
# Send text to pane
tmux send-keys -t mysession:1 "echo 'Hello World'"

# Send special key
tmux send-keys -t mysession:1 Enter

# Send multiple keys
tmux send-keys -t mysession:1 "ls -la" Enter
```

### Send Keys Syntax

```bash
send-keys (send) [-FHKlMRX] [-c target-client] [-N repeat-count] [-t target-pane] key ...
```

#### Flags
| Flag | Description |
|------|-------------|
| `-F` | Expand formats in key |
| `-H` | Disable hiding of key data |
| `-K` | Treat key as a key name, not text |
| `-l` | Disable key name lookup |
| `-M` | Send mouse event |
| `-R` | Reset terminal |
| `-X` | Send to copy mode |
| `-c target-client` | Target client |
| `-N repeat-count` | Repeat count |
| `-t target-pane` | Target pane (`session:window.pane` or `%pane_id`) |

### Target Specification

```bash
# Target: session
tmux send-keys -t mysession "text"

# Target: session:window
tmux send-keys -t mysession:1 "text"

# Target: session:window.pane
tmux send-keys -t mysession:1.0 "text"

# Target: pane ID
tmux send-keys -t %1 "text"

# Target: window (in current session)
tmux send-keys -t :1 "text"

# Target: pane (in current session:window)
tmux send-keys -t :1.0 "text"
```

### Send Special Keys

```bash
# Send Enter key
tmux send-keys Enter

# Send Tab
tmux send-keys Tab

# Send Escape
tmux send-keys Escape

# Send Ctrl combinations
tmux send-keys C-c
tmux send-keys C-d

# Send function keys
tmux send-keys F1
tmux send-keys F5

# Send arrow keys
tmux send-keys Up
tmux send-keys Down
tmux send-keys Left
tmux send-keys Right

# Send with repeat count
tmux send-keys -N 5 "x"  # Send 'x' five times
```

### Practical Examples

```bash
# Type command and execute
tmux send-keys -t mysession "npm start" Enter

# Navigate and clear screen
tmux send-keys -t mysession:1 C-l

# Interactive command sequence
tmux send-keys -t mysession "git add ." Enter
tmux send-keys -t mysession "git commit -m 'Update'" Enter

# Send to multiple panes (broadcast)
tmux set-option -t mysession:1 synchronize-panes on
tmux send-keys -t mysession:1 "echo 'Broadcast'" Enter
tmux set-option -t mysession:1 synchronize-panes off
```

### Capture Pane Content

```bash
# Capture pane to buffer
tmux capture-pane -t mysession:1

# Capture and display
tmux capture-pane -t mysession:1 -p

# Capture specific lines
tmux capture-pane -S -100 -p  # Last 100 lines

# Save to file
tmux capture-pane -t mysession:1 -p > output.txt
```

---

## Copy Mode

```bash
# Enter copy mode
tmux copy-mode -t mysession:1

# Send keys in copy mode
tmux send-keys -X -t mysession:1 cursor-up
tmux send-keys -X -t mysession:1 start-of-line
tmux send-keys -X -t mysession:1 begin-selection

# Cancel copy mode
tmux send-keys -X -t mysession:1 cancel
```

### Copy Mode Commands
| Command | Description |
|---------|-------------|
| `cursor-up` | Move cursor up |
| `cursor-down` | Move cursor down |
| `cursor-left` | Move cursor left |
| `cursor-right` | Move cursor right |
| `start-of-line` | Jump to start of line |
| `end-of-line` | Jump to end of line |
| `begin-selection` | Start selection |
| `copy-selection` | Copy selection |
| `cancel` | Cancel copy mode |
| `page-up` | Page up |
| `page-down` | Page down |
| `scroll-up` | Scroll up |
| `scroll-down` | Scroll down |
| `search-forward` | Search forward |
| `search-backward` | Search backward |
| `search-again` | Repeat last search |
| `jump-forward` | Jump forward |
| `jump-backward` | Jump backward |
| `select-word` | Select word |
| `select-line` | Select line |

---

## Configuration

### Configuration File

Default configuration file location: `~/.tmux.conf`

```bash
# Specify custom config
tmux -f /path/to/config.conf

# Source config file
tmux source-file ~/.tmux.conf
```

### Common Configuration Options

```bash
# Set prefix key
set-option -g prefix C-a

# Enable mouse mode
set-option -g mouse on

# Set base index for windows and panes
set-option -g base-index 1
set-window-option -g pane-base-index 1

# Renumber windows when one is closed
set-option -g renumber-windows on

# Set default terminal
set-option -g default-terminal "screen-256color"

# Set status bar
set-option -g status on

# Set window title
set-window-option -g automatic-rename on
```

---

## Display Messages

```bash
# Display message
tmux display-message "Hello World"

# Display with format
tmux display-message -t mysession "Session: #{session_name}"

# Display pane info
tmux display-message -t mysession:1 "Pane: #{pane_current_command}"

# Display message with delay
tmux display-message -d 3000 "This will show for 3 seconds"
```

---

## Automation Examples

### Session Setup Script

```bash
#!/bin/bash
SESSION="dev-env"

# Create session detached
tmux new-session -d -s "$SESSION" -n "editor"

# Add window for server
tmux new-window -t "$SESSION" -n "server"

# Add window for logs
tmux new-window -t "$SESSION" -n "logs"

# Split editor window
tmux split-window -h -t "$SESSION:editor"

# Send commands to panes
tmux send-keys -t "$SESSION:editor.left" "vim ." Enter
tmux send-keys -t "$SESSION:server" "npm run dev" Enter
tmux send-keys -t "$SESSION:logs" "tail -f logs/app.log" Enter

# Attach to session
tmux attach -t "$SESSION"
```

### Process Control

```bash
# Start service in background pane
SESSION="services"
tmux new-session -d -s "$SESSION"
tmux send-keys -t "$SESSION" "redis-server" Enter
tmux split-window -v
tmux send-keys -t "$SESSION:1" "mongod" Enter

# Stop services
tmux send-keys -t "$SESSION:1.0" C-c
tmux send-keys -t "$SESSION:1.1" C-c
```

### Interactive Testing

```bash
# Create test environment
SESSION="test"
tmux new-session -d -s "$SESSION"

# Run tests in background
tmux send-keys -t "$SESSION" "npm test" Enter

# Wait and capture results
sleep 5
tmux capture-pane -t "$SESSION" -p > test-results.txt

# Check for failures
if grep -q "failing" test-results.txt; then
    tmux display-message "Tests failed!"
else
    tmux display-message "Tests passed!"
fi
```

---

## Target Specification Reference

tmux uses a consistent target specification format across all commands:

```
session                = Session name or session ID
session:window         = Window in session
session:window.pane    = Pane in window
:window                = Window in current session
:window.pane           = Pane in current session
window.pane            = Pane in current session
%pane_id               = Pane by unique ID
```

### Examples
```bash
mysession           # Target session
mysession:1         # Target window 1 in mysession
mysession:1.0       # Target pane 0 in window 1 of mysession
:1                  # Target window 1 in current session
:1.0                # Target pane 0 in window 1
%1                  # Target pane with ID %1
```

---

## Command Reference Summary

| Command | Alias | Description |
|---------|-------|-------------|
| `new-session` | `new` | Create new session |
| `attach-session` | `attach` | Attach to session |
| `detach-client` | `detach` | Detach client |
| `list-sessions` | `ls` | List sessions |
| `kill-session` | | Kill session |
| `rename-session` | | Rename session |
| `new-window` | `neww` | Create new window |
| `list-windows` | `lsw` | List windows |
| `select-window` | `selectw` | Select window |
| `kill-window` | `killw` | Kill window |
| `rename-window` | `renamew` | Rename window |
| `split-window` | `splitw` | Split window |
| `list-panes` | `lsp` | List panes |
| `select-pane` | `selectp` | Select pane |
| `kill-pane` | `killp` | Kill pane |
| `resize-pane` | `resizep` | Resize pane |
| `send-keys` | `send` | Send keys to pane |
| `capture-pane` | `capturep` | Capture pane content |
| `display-message` | `display` | Display message |
| `list-commands` | `lscm` | List all commands |

---

## Tips and Tricks

1. **List all available commands**: `tmux list-commands`
2. **Show all key bindings**: `tmux list-keys`
3. **Show configuration options**: `tmux show-options -g`
4. **Debug mode**: Run with `-vvv` for verbose logging
5. **Check version**: `tmux -V`
6. **Kill stuck server**: `tmux kill-server`
7. **Reload config**: `tmux source-file ~/.tmux.conf`

---

## See Also

- tmux manual: `man tmux`
- Configuration examples: `man tmux.conf`
- Format strings: Search for "FORMATS" in tmux manual
- Key bindings: Search for "KEY BINDINGS" in tmux manual
