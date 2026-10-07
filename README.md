# Agent Monitor

Live, on-VM view of everything the AI agent does on this machine
(Debian 13 / GNOME, GTK3).

## What it shows
- **Arrow panel** (top, max 300 px wide) — AI icon (left) ⇄ VM icon (right).
  The upper arrow (pointing left) = agent *reading* from the VM; the lower
  arrow (pointing right) = agent *writing* to it. Both flash green on
  activity and keep running `ops / bytes` counters.
- **Command log** — the exact commands the agent runs, live, with search,
  follow (auto-scroll) and Clear-today. Read commands are grey, writes amber.
- **Tunnel status** (header) — Cloudflare tunnel state with
  Reconnect / Stop / Start, plus a full settings dialog: add/remove ingress
  hostnames, optional automatic DNS route registration, validate →
  backup → apply → restart.

## How capture works
`agent-monitor-install-hook` (run once per user) installs a BASH_ENV /
DEBUG-trap hook to `~/.agent-auto-log` and wires `~/.bashrc`. Every bash
command (including non-interactive ssh sessions) is appended to:

    ~/.agent-monitor/logs/commands-YYYY-MM-DD.log   # daily rotation, kept forever

The GUI tails today's file. `Clear today` truncates only today's file.

## Install

> AI agent working on this machine? Read [SKILL.md](SKILL.md) first.
> Full human manual: [USAGE.md](USAGE.md).
    sudo dpkg -i agent-monitor_1.1.0_all.deb   # deps: python3-gi gir1.2-gtk-3.0
    agent-monitor-install-hook                 # once, as your user

Launch from Activities → "Agent Monitor", or run `agent-monitor`.
Tunnel control needs passwordless sudo for `systemctl`/`cloudflared`
(falls back to pkexec).

## CLI
    agent-monitor              # GUI
    agent-monitor --stats      # today's read/write totals
    agent-monitor --selftest   # classifier + config-parser tests
    agent-monitor --version

## Files
- sources: `src/` in this folder — build with `./build-deb.sh`
- logs: `~/.agent-monitor/logs/`
- tunnel config (edited via the GUI): `/etc/cloudflared/config.yml` —
  every Apply writes a timestamped `.bak-…` copy next to it

## v1.2 — UI refresh
- transfer view moved into a status bar (AI ⇄ VM with **animated dashed
  arrows** — dash speed follows live command flow) + tunnel pill with
  Reconnect/Start/Stop and the settings dialog, both in the top status bar
- full-window log viewer with **odd/even striping**
- **light / dark theme** toggle in the header bar (persisted in
  ~/.config/agent-monitor/theme)
- **clickable paths and URLs** in the log: click a path → selects it in
  Files (nautilus --select); ctrl+click or middle-click → opens it;
  URLs open in the browser
- Clear-today is now an icon-only button

## v1.3 — final polish
- transfer bar narrower (150 px) with the write label under its arrow
- tunnel pill compact (8 pt, minimal height)
- simple outline icons (theme-aware dark/light variants)
- modern CSS pass: rounded search, flat compact buttons, tighter status bar

## v1.4 — context pool (append-to-agent)
- one-line transfer bar: AI [read label] <= <= => => [write label] VM
- tunnel control moved to a titlebar button; sidebar toggle button too
- right sidebar (open by default): **Context** tab (type notes mid-work;
  the agent picks them up at its next break and they disappear) and
  **Rules** tab (permanent context the agent must always apply)
- pool: ~/.agent-monitor/context/{pending,read,rules}
- CLI for agents: `agent-monitor --context-take` (returns new context +
  all rules, marks context read), `--rules`, `--context-add TEXT`,
  `--rule-add TEXT`
- darker stripes in dark mode for clearer row separation

## v1.5 — polish round
- flow bar centric one-liner: [read label] [AI] <---- ----> [VM] [write label]
- full-width striped log rows (painted, not text tags); no log tooltips
- sidebar: segmented full-width tab stripe, padded collapsible context
  cards (8pt), padded inputs

## v1.5.1 — hotfix: frozen sidebar timers
- GLib timeout callbacks must return True to re-arm; refresh_ctx_tabs and
  refresh_tunnel returned None, so the sidebar/pill refreshed exactly once
  after launch and then froze (context cards never appeared/vanished live).
  Both now run on self-re-arming ticks; ctx refresh also 1.5s -> 1s and
  wrapped in try/except so it can never die. --screenshot delay override:
  AM_SHOT_DELAY ms.

## v1.5.2 — log scroll behavior
- auto-follow no longer moves the cursor/selection (temporary mark scroll)
- tail semantics: scrolling up to read pauses auto-follow; it resumes
  automatically when you return to the bottom (Follow checkbox is the
  master switch; threshold 60 px)

## v1.5.3 — jump-to-latest FAB
- floating action button (bottom-right of the log) appears whenever you
  scroll away from the bottom; click to jump to latest and resume follow;
  hides itself when at the bottom

## v1.5.4 — startup at latest
- the log opens scrolled to the end (latest lines) instead of the top;
  the jump-to-latest FAB stays hidden until you actually scroll up

## v1.5.5 — follow reliability
- root cause of follow dropping: scrolls ran synchronously right after
  inserts, before text layout -> landed short -> next poll saw "not at
  bottom" and silently stopped following. Scrolls are now deferred to
  after layout (idle + 60 ms). --screenshot prints BOOT-STATE ground truth.

## v1.5.6 — follow cannot die silently
- auto-follow now pauses ONLY on a genuine user scroll (adjustment
  value-changed outside the auto-scroll window) and resumes when you
  scroll back to the bottom, click the FAB, or re-enable Follow.
  A short-landing programmatic scroll can no longer be mistaken for the
  user scrolling away (that false positive silently killed follow).

## v1.6.0 — PhpStorm New UI style context pool
- rounded panels everywhere (log view, sidebar, cards, composer)
- single persistent chat composer: content survives tab switches; the
  send button routes to the active tab (blue = context, purple = rules)
  and is icon-only
- context and rule cards are editable inline (pencil button)
- rules accented purple; transfer labels neutral; write arrow turns
  amber (not green) when active
- search matches are highlighted inside log lines
- FAB redrawn as a stem-less chevron, blue to match the send button

### v1.6.0 addendum
- log timestamps render in local time, Jalali calendar by default; calendar
  button in the toolbar switches Jalali/Gregorian (display only - stored
  timestamps remain GMT/UTC)
- follow hardening: pauses on genuine wheel-scroll up (and scrollbar
  departure), guard window 1.5s, transitions logged to stderr
  (/tmp/agent-monitor.log) for diagnosis
