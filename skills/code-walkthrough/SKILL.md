---
name: code-walkthrough
description: Builds a step-by-step, plain-words walkthrough of how a PR, a branch, or the current diff was written, as a lavish HTML page with a left sidebar (Overview, Step 1..N, Gaps). The Overview gives the problem and the proposed solution; each Step gives one logical chunk of code, what changed, and why. Use when the user says "walk me through this PR", "explain how this was implemented", "how did you write this", wants a knowledge sync before answering an implementation decision, or types /lavish-ext:code-walkthrough.
argument-hint: "[PR number or URL | branch | empty for the current branch]"
---

# Code walkthrough

Write a page that explains how a change was written, from the problem to the
code, so that someone new to the company can follow it.

## 0. Require lavish (hard gate: do this first, every time)

This skill only works with the `lavish` skill and `lavish-axi`. Before you read
any code or write any file, run:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/skills/code-walkthrough/scripts/require-lavish.sh"
```

If `CLAUDE_PLUGIN_ROOT` is not set, run `scripts/require-lavish.sh` from this
skill's folder.

- Exit 0: continue.
- Any other result, or the script cannot run: **stop.** Do not build the page,
  do not fall back to plain HTML, Markdown, or a chat answer, and do not install
  lavish yourself. Show the user the script's message and tell them to install
  lavish with `npx skills add kunchenguid/lavish-axi`, then run
  `/lavish-ext:code-walkthrough` again.

## Why this exists

Midway through an implementation, the agent often asks the user to make a
decision. The user cannot answer well without knowing how the code works. It is
like asking someone a question that only the author of the code can answer.
This page closes that gap: the user reads the problem, the plan, and each logic
step, then decides.

A plain PR description or a line-by-line diff does not do this. The PR body is
too short to explain the reasons. The diff is in file order, not in the order
of the logic, and it shows what changed but not why.

## Request

$ARGUMENTS

## Base workflow: follow the lavish skill

This skill extends the `lavish` skill. Read it and follow its workflow; do not
copy it here. In short:

1. Open the playbooks before you write HTML: `npx -y lavish-axi playbook code`
   and `npx -y lavish-axi playbook diagram` (add `comparison` or `table` if a
   step needs one). Run `npx -y lavish-axi design` for the CDN snippets.
2. Pick the design source in lavish's priority order: the user's request, then
   the project's own design tokens and fonts, then lavish's Tailwind + DaisyUI
   CDN. Say which one you used and why when you deliver.
3. Open the page with `npx -y lavish-axi <file>`, then poll with
   `npx -y lavish-axi poll <file> --agent-reply "<one line>"`, following
   lavish's foreground-poll rules.

## 1. Find the change

- Input is a PR number or URL, a branch, or nothing. Nothing means the current
  branch compared with its base branch.
- Read the real diff: `gh pr diff <n>` for a PR, else
  `git diff <base>...HEAD` (add uncommitted work with `git diff HEAD` if the
  user means "the current diff").
- Read the PR body, the ticket or spec it links to, and the commit messages.
  Then read the changed files in full, not only the hunks, so you know what the
  code around each change does.

## 2. Plan the steps

- Order the steps by the logic of the solution, not by file or commit order.
  A usual order: data model, then core logic, then edge cases and failure
  paths, then UI.
- One step is one chunk of code that has a logic of its own. It can span
  several files when they only make sense together. Do not go line by line.
- 6 to 12 steps is typical. Merge tiny steps; split a step that has two
  separate reasons.

## 3. Write the pages

Start from `references/page-skeleton.html` in this skill folder. It has the
sidebar, one-section-at-a-time view, Previous/Next buttons, phone layout, and a
code viewer that uses `@pierre/diffs` `File` from esm.sh, as the lavish `code`
playbook says.

**Overview page**

- The problem in plain words, with a concrete story about a named person
  ("Anna clicks Upgrade, pays, and the page still says Free").
- The proposed solution in a few short paragraphs.
- A small map of the steps: a short list or a Mermaid diagram (per the
  `diagram` playbook) that names each step in one line.

**Each step page**

- **What changed**: plain words, two to five sentences.
- **The code**: the chunk or chunks, each with its file path and a one-line
  reason to look at it.
- **Why**: the reason for this design, and why not the obvious simpler thing.
  This is the most important part. Say what would break with the simpler way.
- **Tests**: a short list, one line per test: what it checks. Keep it brief;
  the user cares most about the logic and the reasons.

**Gaps page (optional)**

- What this change does not do yet, known limits, and the ticket that covers
  each one.

## Rules for the content

- **Copy every code snippet from the current code.** Read the file and copy the
  lines. Never write a snippet from memory: a wrong snippet makes the whole
  page untrustworthy. Trim with a `# ...` comment in the file's own comment
  style, never by rewriting.
- Put each snippet in a `<script type="text/plain">` block, as the skeleton
  does, so the HTML does not mangle it. If the code contains `</script>`,
  write it as `<\/script>`.
- Write for someone new to the company. Define each domain term the first time
  it appears. Explain jargon in one plain line ("idempotent: running it twice
  has the same result as running it once").
- Prefer a concrete story or a small table over abstract wording. Use short
  sentences, one idea each.
- Keep caveats, and say them plainly.

## 4. Save, open, and keep the review loop

- Save the page in the repository's agent scratch folder when it exists (in a
  worktree: `<git-dir>/agent-scratch/lavish/`, where `<git-dir>` is
  `git rev-parse --absolute-git-dir`). Otherwise save it in `.lavish/` in the
  working directory. Name it `walkthrough-<pr-or-branch>.html`.
- Never commit the page.
- Open it with `npx -y lavish-axi <file>` and poll with an `--agent-reply` that
  says where to start reading.
- When the user annotates a passage ("I don't get this", or a question):
  1. Rewrite that passage in place, in plainer words, with an example.
  2. Put the answer to a question in the page, next to the passage, not only
     in chat.
  3. Save, then poll again with a short `--agent-reply` that says what changed.
- When the user answers a decision from the page, act on it in the code only
  as the surrounding task allows.

## 5. Keep it current

When the implementation changes later in the session, update the walkthrough
so that every step and snippet matches the current code. Re-copy the changed
snippets from the files. Add, remove, or reorder steps when the logic changed.
