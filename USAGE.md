# Agent Monitor — usage

Live, on-VM view of everything an AI agent does on the machine: command
log, read/write flow, Cloudflare tunnel control, and a context pool the
owner uses to steer the agent mid-work.

## Install

From a release (Debian/Ubuntu):

    wget https://github.com/omidgfx/agent-monitor/releases/latest/download/agent-monitor_1.5.5_all.deb
    sudo dpkg -i agent-monitor_1.5.5_all.deb
    sudo apt install -f          # if deps missing (python3-gi, gir1.2-gtk-3.0)

Or build from source: ./build-deb.sh && sudo dpkg -i agent-monitor_*_all.deb

First run per user (enables command capture):

    agent-monitor-install-hook

Launch: Activities -> Agent Monitor, or run: agent-monitor

## The window

- Titlebar: theme toggle (light/dark, remembered), tunnel button, sidebar
  toggle (sidebar opens by default).
- Log: every captured bash command, colored (grey read / amber write),
  striped rows, full-text search, Follow checkbox. Paths are links:
  click = select in Files, ctrl/middle-click = open. URLs open in browser.
- Jump-to-latest FAB appears bottom-right when you scroll up; click to
  return to live tail.
- Transfer bar (bottom): [read label] [AI] <---- ----> [VM] [write label]
  with live ops/bytes; dashes animate with command flow.
- Status bar: log path, line count, read/write totals.

## Tunnel

Titlebar pill: green up / amber connecting / red failed, plus link count.
Menu: Reconnect / Start / Stop (stop warns about tunnel-SSH sessions).
Tunnel Settings: add/remove ingress hostnames (hostname + service), optional
DNS route registration, then validate -> timestamped backup of
/etc/cloudflared/config.yml -> apply -> optional restart, with per-step
status. Removes just drop the ingress rule (notes any DNS to clean).

## Context pool (owner -> agent)

Right sidebar, two tabs:
- Context — type + Send (or Ctrl+Enter). Cards stack, collapsible,
  deletable. When the agent picks them up they are marked read and vanish.
- Rules — permanent instructions the agent receives with every pickup; it
  can never remove them (you can delete them here).

Pool lives in ~/.agent-monitor/context/{pending,read,rules}. Logs live in
~/.agent-monitor/logs/commands-YYYY-MM-DD.log (daily files, kept forever;
Clear-today truncates only today file).

## CLI

    agent-monitor                  # GUI
    agent-monitor --stats          # today read/write totals
    agent-monitor --selftest       # classifier + parser tests
    agent-monitor --context-take   # agent pickup: new context + rules
    agent-monitor --context-add "text"
    agent-monitor --rule-add "text"
    agent-monitor --rules
    agent-monitor --version

## How capture works

agent-monitor-install-hook installs a BASH_ENV DEBUG-trap hook to
~/.agent-auto-log and wires ~/.bashrc. Every bash command (including
non-interactive SSH sessions) is appended to today log. Daily rotation by
filename; nothing is auto-deleted.

## Troubleshooting

- Sidebar cards not updating: the GUI refresh tick is 1s — give it a
  second; check agent-monitor still running.
- No commands captured: was agent-monitor-install-hook run as THIS user?
- Tunnel dead everywhere: systemctl is-active cloudflared on the VM; the
  app Reconnect button or the detached restart in SKILL.md.
- Screenshots for debugging: AM_SHOT_DELAY=ms agent-monitor --screenshot
  /tmp/out.png (prints BOOT-STATE ground truth).
