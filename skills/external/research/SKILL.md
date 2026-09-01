---
name: research
description: Investigate a question against high-trust primary sources and capture the findings as a cited Markdown file. Use when the user wants a topic researched, documentation or API facts gathered, or reading legwork separated from the main task.
metadata:
  vault-source: "affiliate-pro-skills-full.zip"
  vault-source-sha256: "e23edad2c53db59d9e10445c04e8c9b5733e47e69e06c7585505658dbf4fe45f"
  vault-body-sha256: "3d62db42fa43265bd56ed750c1324b8b0d859f26d0793e126dff81d164ab3a27"
  vault-entered: "2026-09-01"
---

Research in an isolated delegated agent when the runtime supports delegation; this keeps the reading context separate and may run concurrently with the main task. Otherwise execute the same workflow sequentially in the current agent. Delegation is an optimization, not a prerequisite.

Use the runtime's available web, documentation, repository, or local-file capabilities. Prefer live primary sources when the question depends on current facts. If live access is unavailable, use only sources already present locally, label the limitation, and do not imply that current external facts were verified.

Its job:

1. Investigate the question against **primary sources** (official docs, source code, specs, first-party APIs), not a secondary write-up of them. Follow every claim back to the source that owns it.
2. Write the findings to a single Markdown file, citing each claim's source.
3. Save it where the workspace already keeps such notes; match the existing convention. If no writable filesystem is available, return the complete Markdown in the response and state that it could not be saved.
