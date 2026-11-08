# lavish-ext

Lavish extension: a Claude Code plugin with skills that build on the `lavish`
skill to turn agent work into HTML pages you can read and annotate.

```text
/lavish-ext:code-walkthrough              the current branch vs its base
/lavish-ext:code-walkthrough 482          a PR number or URL
/lavish-ext:code-walkthrough my-branch    a branch
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
  ([source](https://github.com/kunchenguid/lavish-axi)). `code-walkthrough`
  checks for it first (`scripts/require-lavish.sh`) and refuses to run without it.
- `lavish-axi`, run through `npx -y lavish-axi`; no global install is needed.
- `gh` for PR input, and `git`.

## Skills

| Skill              | What it does                                                         |
| ------------------ | -------------------------------------------------------------------- |
| `code-walkthrough` | Step-by-step, plain-words walkthrough of a PR, branch, or diff        |

The page skeleton is in
`skills/code-walkthrough/references/page-skeleton.html`.
