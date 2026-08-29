---
type: skill
name: handoff
title: "Handoff"
description: "Compact the current conversation into a handoff document for another agent to pick up."
created_at: "2026-08-28T19:44:30-04:00"
timezone: America/Montreal
status: ADOPTED-V1
disable-model-invocation: true
argument-hint: "What will the next session be used for?"
metadata-upstream-repo: "github.com/mattpocock/skills"
metadata-upstream-version: "1.2.3"
metadata-upstream-license: "MIT"
metadata-upstream-body-sha256: "ccdb880c33de0e814b6cbbe24cdd82b938660d62d81da7eccad6549bb83b37f1"
---

Write a handoff document summarising the current conversation so a fresh agent can continue the work. Save to the temporary directory of the user's OS - not the current workspace.

Include a "suggested skills" section in the document, naming which skills the next agent should call the Skill tool for.

Do not duplicate content already captured in other artifacts (specs, plans, ADRs, issues, commits, diffs). Reference them by path or URL instead.

Redact any sensitive information, such as API keys, passwords, or personally identifiable information.

If the user passed arguments, treat them as a description of what the next session will focus on and tailor the doc accordingly.
