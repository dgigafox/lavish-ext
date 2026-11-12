# lavish-ext

Lavish extension: a Claude Code plugin with skills that build on the `lavish`
skill to turn agent work into HTML pages you can read and annotate.

```text
/lavish-ext:code-walkthrough              the current branch vs its base
/lavish-ext:code-walkthrough 482          a PR number or URL
/lavish-ext:code-walkthrough my-branch    a branch
/lavish-ext:ticket-explainer JOBS-1603    a Jira key or URL
```

## Why it exists

Midway through an implementation, the agent often asks you to decide something.
You cannot answer well without knowing how the code was written. The PR body is
too short, and the diff is in file order and does not say why.

`code-walkthrough` writes a page with a left sidebar: an **Overview** (the
problem in plain words, with an example, and the proposed solution), then
**Step 1..N** (one logical chunk of code each: what changed, the code, why, and
a short note on tests), then an optional **Gaps** page. You annotate anything
unclear, and the agent rewrites that passage in place.

Before the code exists, the same gap appears with a ticket. A ticket is written
for the people who were there when it was made, and it does not say what
changed since. `ticket-explainer` writes a page for someone new to the company:
the terms first, then why the ticket exists, the problem, the fix, what "done"
means, and where it stands today. It checks each claim against the current
code and Jira, and it lists stale ticket state as open questions. It only
reads; it never edits Jira or code.

## Install

From the `dgigafox` marketplace:

```text
/plugin marketplace add dgigafox/claude-plugins
/plugin install lavish-ext@dgigafox
```

While developing, `claude --plugin-dir ~/Projects/lavish-ext` loads the working
copy without installing it.

## Requirements

- **The `lavish` skill is required.** Install it with
  `npx skills add kunchenguid/lavish-axi`
  ([source](https://github.com/kunchenguid/lavish-axi)). Every skill checks for
  it first (`scripts/require-lavish.sh`) and refuses to run without it.
- `lavish-axi`, run through `npx -y lavish-axi`; no global install is needed.
- `code-walkthrough`: `gh` for PR input, and `git`.
- `ticket-explainer`: the Atlassian MCP signed in to your Jira site, or the
  `acli` CLI as a fallback, and `git`.

## Skills

| Skill              | What it does                                                         |
| ------------------ | -------------------------------------------------------------------- |
| `code-walkthrough` | Step-by-step, plain-words walkthrough of a PR, branch, or diff        |
| `ticket-explainer` | Explains one Jira ticket to someone new to the company                |

Each skill keeps its page skeleton in `skills/<skill>/references/page-skeleton.html`.
The shared lavish gate is `scripts/require-lavish.sh`.
