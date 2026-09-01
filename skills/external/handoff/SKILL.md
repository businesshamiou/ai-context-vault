---
name: handoff
description: "Compact the current conversation into a handoff document for another agent to pick up."
license: "MIT"
metadata:
  upstream-repo: "github.com/mattpocock/skills"
  upstream-version: "1.2.3"
  vault-source: "library-v1-converted"
  vault-source-sha256: "e23edad2c53db59d9e10445c04e8c9b5733e47e69e06c7585505658dbf4fe45f"
  vault-body-sha256: "ccdb880c33de0e814b6cbbe24cdd82b938660d62d81da7eccad6549bb83b37f1"
  vault-entered: "2026-09-01"
  claude-code-disable-model-invocation: "true"
  claude-code-argument-hint: "What will the next session be used for?"
---

Write a handoff document summarising the current conversation so a fresh agent can continue the work. Save to the temporary directory of the user's OS - not the current workspace.

Include a "suggested skills" section in the document, naming which skills the next agent should call the Skill tool for.

Do not duplicate content already captured in other artifacts (specs, plans, ADRs, issues, commits, diffs). Reference them by path or URL instead.

Redact any sensitive information, such as API keys, passwords, or personally identifiable information.

If the user passed arguments, treat them as a description of what the next session will focus on and tailor the doc accordingly.
