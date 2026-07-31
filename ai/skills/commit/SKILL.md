---
name: commit
description: "Create consistently formatted Git commits while recording human and AI-agent responsibility: preserve the user's configured identity as committer, assign the integrating model and reasoning effort as author, format subjects by scope and type, and use conventional Git trailers for distinct contributing agents. Use when creating commits with agent attribution, documenting multi-agent contributions, amending agent metadata, or rewriting recent commits to add or correct author, subject, and trailer records."
---

# Git Agent Attribution

Attribute commits without replacing human responsibility: keep the configured Git user as committer and record only agents that materially contributed to the commit.

## Apply the attribution policy

1. Inspect the worktree, current branch, staged scope, recent commits, upstream, and configured identity.
2. Preserve `git config user.name` and `git config user.email` as committer. Do not set `GIT_COMMITTER_NAME`, `GIT_COMMITTER_EMAIL`, or `--reset-author`.
3. Identify the harness that runs the agent. Use the lowercase platform name as `{harness}`; for example, use `codex` when the agent runs in Codex. If the harness is unavailable, ask the user instead of inventing it.
4. Identify the agent that integrated and owns the final change. Use it as the single author:

   ```text
   {model}-{reasoning_effort}@{harness} <{harness}@ai.invalid>
   ```

   Use the real model identifier and reasoning effort available in the current environment, normalized to lowercase and joined with hyphens—for example, `gpt-5.6-sol-high@codex` when running in Codex. Never omit the reasoning effort when it is available. If the model identifier already includes the effort suffix, do not append it again. If either value is unavailable, ask the user instead of inventing it.
5. Record other models with conventional trailers according to their material role:
   - Code or artifact contributor: `Co-authored-by`
   - Reviewer: `Reviewed-by`
   - Tester: `Tested-by`
   - Problem reporter: `Reported-by`
   - Solution proposer: `Suggested-by`
   - Other material assistance: `Helped-by`
6. Prefer one commit per agent when contributions are cleanly separable. For a shared commit, use the final integrator as author and trailers for the others.
7. Compare trailer identities with the author by the full `{model}-{reasoning_effort}@{harness}` identifier, not agent instance. If a sub-agent uses the same full identifier as the author, omit all of its trailers even when it performed separate work. For every other identifier, record each distinct material role it performed. For example, include both `Reviewed-by` and `Tested-by` when the same non-author agent reviewed and tested the change. Remove only exact duplicate trailers for the same identifier and role.
8. Verify the resulting author, committer, subject, and trailers with `git log`.

Do not credit an agent merely because it was spawned, consulted, or listed. Credit only contributions used in the committed result.

## Format the commit subject

Format a commit subject as:

```text
{scope}: {type}: {description}
```

- Derive `scope` from the staged change, using the narrowest recognizable scope name such as `tui`, `core`, or `app-server`.
- Omit `scope` when the change is cross-cutting, spans a broad scope, or is general:

  ```text
  {type}: {description}
  ```

- Use a concise lowercase `type` that classifies the change, such as `fix`, `improve`, `docs`, `feat`, `test`, `refactor`, `build`, `ci`, or `chore`.
- Write `description` as a concise summary of the committed change.

Examples:

```text
tui: fix: preserve selection after refresh
core: improve: reuse MCP client sessions
docs: explain remote executor setup
```

## Format trailers

Use standard co-author trailers for agents that directly produced committed content:

```text
Co-authored-by: {model}-{reasoning_effort}@{harness} <{harness}@ai.invalid>
```

Use `{harness}@ai.invalid` for every agent author and trailer identity, where `{harness}` is the platform running the agent. In Codex, use `codex@ai.invalid`. Distinguish agents by the `{model}-{reasoning_effort}@{harness}` display name rather than by email. Use conventional role trailers for non-authoring work:

```text
Reviewed-by: o3-high@codex <codex@ai.invalid>
Tested-by: gpt-5.6-terra-medium@codex <codex@ai.invalid>
Reported-by: o4-mini-high@codex <codex@ai.invalid>
```

Add trailers with repeated `--trailer` options when possible so Git formats them correctly.

Do not use custom `Agent-*` trailers. Do not add `Signed-off-by` unless the user explicitly requests the certification required by the project's DCO or contribution policy.

## Create a new attributed commit

Confirm the staged files contain only the intended change, then commit without overriding the committer:

```bash
git commit \
  --author="gpt-5.6-sol-high@codex <codex@ai.invalid>" \
  --trailer="Co-authored-by: o3-high@codex <codex@ai.invalid>" \
  --trailer="Reviewed-by: gpt-5.6-terra-medium@codex <codex@ai.invalid>" \
  --trailer="Tested-by: gpt-5.6-terra-medium@codex <codex@ai.invalid>" \
  -m "tui: feat: describe the change"
```

Omit trailers that do not apply. If a reviewer, tester, or co-author is also `gpt-5.6-sol-high@codex`, omit all trailers for that full identifier because it is already represented as author. Otherwise, keep every applicable distinct role, as shown by the reviewer and tester trailers for `gpt-5.6-terra-medium@codex` above.

## Amend or rewrite attribution

For the latest commit, amend only the requested metadata:

```bash
git commit --amend --no-edit \
  --author="gpt-5.6-sol-high@codex <codex@ai.invalid>"
```

For multiple recent commits:

1. Confirm the exact commit range and ensure the worktree is clean.
2. Check whether the commits have an upstream or were pushed.
3. Warn that rewriting changes commit hashes and invalidates signatures.
4. Rewrite only the requested commits, preserving messages and content.
5. Never force-push unless the user explicitly requests it; use `--force-with-lease` rather than `--force` when authorized.

## Verify

Inspect both identities and the full message after committing or rewriting:

```bash
git log -1 --format='commit %H%nauthor: %an <%ae>%ncommitter: %cn <%ce>%nsubject: %s%n%n%b'
git status --short --branch
```

The expected result is:

- Author: integrating agent's full model-and-effort identity
- Committer: configured human Git identity
- Subject: `{scope}: {type}: {description}`, or `{type}: {description}` when scope is omitted
- Body: only applicable conventional trailers for distinct model identities
- Worktree: unchanged except for the requested commit operation
