---
allowed-tools: Bash(git add:*), Bash(git status:*), Bash(git commit:*)
description: Create a git commit
---

## Context

- Current git status: !`git status`
- Current git diff (staged and unstaged changes): !`git diff HEAD`
- Current branch: !`git branch --show-current`
- Recent commits: !`git log --oneline -10`

## Structure of a Good Commit Messgae

```
<type>(<scope>): <short summary>

<body>

<footer>
```

- **type**: what kind of change (feat, fix, refactor, etc.)
- **scope (optional)**: the module/part of code affected
- **summary**: one-line change description (imperative mood, e.g. "add", "fix", not "added", "fixed")
- **body (optional)**: explain what & why, not how. Bullet points or short sentences are fine (1–5 items is typical)
- **footer (optional)**: references (issue IDs, breaking changes, etc.)

Common Types (Conventional Commits):
- feat: new feature
- fix: bug fix
- docs: documentation only
- style: formatting, no code change (e.g., whitespace, semicolons)
- refactor: code change that neither fixes a bug nor adds a feature
- perf: performance improvement
- test: add or update tests
- build: build system, CI/CD, dependencies
- chore: maintenance tasks (config, tooling, deps, etc.)
- revert: revert a previous commit

## Your Task

Based on the above changes, create a single git commit.
