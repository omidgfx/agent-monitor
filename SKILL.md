# Agent Monitor — Skill for AI agents

You (the AI agent) are being watched through this app while you work on the
owner machine — and more importantly, the owner talks to you through it
while you work. This file is the operating law.

## The context pool (HIGHEST PRIORITY)

The owner appends context WHILE you work. He will not wait for you to
finish. Everything he types is a high-priority instruction from outside —
it can help, steer, correct, or pivot the entire line of work to something
else. Never optional. Never deferred to "after the task".

Pickup command (run it constantly — between EVERY step: between thoughts,
between file edits, between decisions, between tool batches, before
responding, before claiming done, first action of every response):

    agent-monitor --context-take

Output sections:
- NEW CONTEXT — items you must incorporate IMMEDIATELY (top of your task
  stack; pivot without protest if it says so). They are auto-marked read
  and vanish from the owner sidebar — that is his confirmation signal.
- RULES — permanent, returned on EVERY pickup, always apply. Re-read them
  every time; a new one can appear at any moment.

Add from shell (what the GUI does):

    agent-monitor --context-add "text"     # one-shot context
    agent-monitor --rule-add "text"        # permanent rule
    agent-monitor --rules                  # list rules only

Hard limits: never delete/edit/move anything in
~/.agent-monitor/context/ yourself — only --context-take moves
pending -> read. Rules are managed by the owner in the GUI only.

## What the owner sees

- Every command you run, live (grey = read, amber = write), with per-line
  search and your read/write op + byte counters. Assume he watches.
- Tunnel state + your systemctl actions.
- Whether his context cards were picked up (they vanish when you take them).

## Useful for you

    agent-monitor --stats     # today totals — quick self-audit
    tail -f ~/.agent-monitor/logs/commands-2026-10-07.log   # what you already did

## Tunnel trouble

If every SSH/tunnel call fails: the tunnel is down, not the machine.
Restart (detached, expect ~60s drain):
    sudo -n sh -c "setsid sh -c \"sleep 2; systemctl restart cloudflared\" &"

## Never

- kill or restart the agent-monitor GUI process
- edit anything under ~/.agent-monitor/ directly
- restyle or rebuild its UI unless the owner asks (it is final)
