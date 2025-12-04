## Instructions

1. Run `git status` and `git diff HEAD` to inspect all changes.
2. If there are unstaged changes, run `git add -A` to stage them.
3. Analyze the combined diff and generate a Conventional Commit message:
   - Format: `<type>(<scope>): <short summary>`
   - Summary must be ≤ 73 characters.
   - Valid types include: feat, fix, docs, refactor, style, test, chore, perf, build, revert.
4. (Optional) Include 1–3 short bullet points summarizing the key changes.
   - Bullet points must be short phrases.
   - Add them only when they improve clarity.
5. After generating the commit message, run the `git commit` command to create the commit.

## Best Practices

- Use **present tense** (e.g., “add feature”, “fix crash”).
- Focus on **why** the change is made, not code-level details.
- Keep the summary concise and avoid trailing punctuation.
- Only stage files when necessary; do not restage unchanged files.