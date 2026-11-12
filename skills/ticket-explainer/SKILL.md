---
name: ticket-explainer
description: Explains one Jira ticket to someone new to the company, as a lavish HTML page with a left sidebar (Overview, Terms, Why it exists, The problem, The fix, Done when, Status, Next). It reads the ticket, its comments, parent, linked tickets and the code it names, checks each claim against the current code and Jira, and flags stale ticket state. Read-only. Use when the user asks what a Jira ticket is, why it was created, what it is for, how it relates to other tickets, wants to be onboarded onto a ticket before they work on it, or types /lavish-ext:ticket-explainer.
argument-hint: "<Jira key or URL, e.g. JOBS-1603>"
---

# Ticket explainer

Write a page that explains one Jira ticket so that someone new to the company
understands why it exists, what it changes, and where it stands now.

## 0. Require lavish (hard gate: do this first, every time)

This skill only works with the `lavish` skill and `lavish-axi`. Before you read
the ticket or write any file, run:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/require-lavish.sh"
```

If `CLAUDE_PLUGIN_ROOT` is not set, run `../../scripts/require-lavish.sh` from
this skill's folder (the plugin root's `scripts/` folder).

- Exit 0: continue.
- Any other result, or the script cannot run: **stop.** Do not build the page,
  do not fall back to plain HTML, Markdown, or a chat answer, and do not install
  lavish yourself. Show the user the script's message and tell them to install
  lavish with `npx skills add kunchenguid/lavish-axi`, then run
  `/lavish-ext:ticket-explainer` again.

## Why this exists

A ticket is written for people who were there when it was made. A newcomer
reads "confirmed lead NV-18, latent, twin of `PostingApiCompanyScope`" and
understands none of it. The ticket also does not say what happened since: the
code moved, a linked ticket was fixed elsewhere, or a PR sits in an old
repository.

A chat answer does not fix this. It is long, it is gone after the next message,
and the user cannot point at the sentence they do not understand. The page puts
the terms first, the reason second, and the current state last, and the user
annotates what is unclear.

## Request

$ARGUMENTS

## Base workflow: follow the lavish skill

This skill extends the `lavish` skill. Read it and follow its workflow; do not
copy it here. In short:

1. Open the playbooks before you write HTML: `npx -y lavish-axi playbook explanation`
   and `npx -y lavish-axi playbook diagram`. Add `code` when the page shows
   code, and `table` or `comparison` when a section needs one. Run
   `npx -y lavish-axi design` for the CDN snippets.
2. Pick the design source in lavish's priority order: the user's request, then
   the design tokens and fonts of the project that the ticket is about, then
   lavish's Tailwind + DaisyUI CDN. Say which one you used and why when you
   deliver.
3. Open the page with `npx -y lavish-axi <file>`, then poll with
   `npx -y lavish-axi poll <file> --agent-reply "<one line>"`, following
   lavish's foreground-poll rules.

## 1. Read the ticket

The input is a Jira key (`JOBS-1603`) or a Jira URL. This skill is for Jira
only. For anything else, tell the user and stop.

Use the Atlassian MCP: `getAccessibleAtlassianResources` once for the
`cloudId`, then `getJiraIssue` with view `evidence` and
`listJiraIssueComments`. If the MCP is not available or fails, use the
`atlassian-cli` skill (`acli jira workitem view <KEY> --fields '*all' --json`).

**Not signed in:** if the MCP asks for authentication, start its
`authenticate` flow, give the user the URL, and stop the turn. Do not guess the
ticket from the branch name or the code. Continue when the user says they are
signed in.

Read, in this order:

1. The ticket: summary, type, status, labels, assignee, reporter, due date,
   description, and every comment.
2. The parent (epic or Story): its goal and its rules. An audit epic or a
   tracking Story often holds the "why" that the ticket leaves out.
3. Each linked ticket (`issuelinks`) and its comments. A result comment on a
   linked ticket often records the decision that created this ticket.
4. The PR links in the comments and in the `Development` field. Treat that
   field as a hint: it can be stale (`isStale: true`) or point at a repository
   that no longer holds the code.

Read a linked ticket's own links only when the user asks or when this ticket
cannot be understood without them.

## 2. Read the code and the project language

- Find each file, module, function, and test that the ticket names. Paths and
  line numbers in a ticket are often from an older commit: find the same code
  in the current default branch.
- Read the code around each named spot, not only the line.
- Check whether the fix is already on the default branch: the code change, the
  named test, or a commit with the ticket key (`git log --oneline -i --grep=<KEY>`).
- Read the project's `GLOSSARY.md` (and the glossary of the app that the ticket
  is for). Use its terms with its spelling, and define each one on the page.

## 3. Check every claim

Before a fact goes on the page, check it against its source:

- **Current code**: does the file, check, or test still exist where the ticket
  says? Is the bug still there?
- **Current Jira**: is a "blocking" or "related" ticket actually open? A ticket
  can be fixed by another ticket's PR and never closed.
- **Ticket hygiene**: a status, label, or due date that disagrees with the
  facts. Examples: a triage label that says "needs a spec" on a ticket that
  already names its fix, a past due date, a ticket open after its work merged.

Put each disagreement in the Status section as an open question, with the
evidence. Do not fix it in Jira: this skill is read-only.

Mark each statement as one of two kinds:

- **Verified**: you read it in the code, Jira, or git. Cite the file, ticket,
  or commit.
- **Inferred or proposed**: your reading, or code that is not merged. Label it
  plainly, for example "Sketch, not merged code".

## 4. Write the page

Start from `references/page-skeleton.html` in this skill folder. It has the
sidebar, one section at a time, Previous/Next, the phone layout, a slot for an
inline SVG figure, and a code viewer that uses `@pierre/diffs` from esm.sh, as
the lavish `code` playbook says.

| Section | Content |
| --- | --- |
| **Overview** | The ticket in one plain sentence: what is wrong or missing, and what the ticket changes. Then badges: type, priority, status, assignee, parent. |
| **Terms** | Each domain term the reader needs, one card each, in plain words, from the glossary. Put any feature flag or switch that changes the risk here too. |
| **Why it exists** | The chain that created the ticket, as a timeline: epic, investigation, result, this ticket. Name each ticket key and what it decided. |
| **The problem** | A concrete story ("Company A's key asks for Company B's application and gets it"). One inline SVG figure for the flow, per the `diagram` playbook. An everyday analogy. Then the cause in code terms, with file references. |
| **The fix** | What the ticket proposes, and why this way and not the obvious simpler way. Show code only when it helps. Label proposed code as a sketch. Show an existing precedent in the codebase when the fix copies one. |
| **Done when** | The acceptance criteria as a checklist, in plain words. |
| **Status** | A table: is the fix on the default branch, PR state, due date, the worktree or branch, and each open question from step 3. |
| **Next** | The files to read first, and related tickets with one line each. Do not end with a summary that repeats the page. |

Write for someone new to the company:

- Lead each section with its answer, then the details.
- Short sentences, one idea each. Define jargon in one plain line.
- Prefer a concrete story, a table, or a figure to abstract wording.
- Keep the caveats, and say them plainly.
- Copy every code snippet from the current file. Never write a snippet from
  memory. Trim with a comment in the file's own comment style.

**Security tickets** (a `security` label, an audit epic, or a vulnerability in
the text): add a line on the page that the content is internal. Never run
`lavish-axi share`, because it publishes the page on a public host.

## 5. Save, open, and keep the review loop

- Save the page in the repository's agent scratch folder when it exists (in a
  worktree: `<git-dir>/agent-scratch/lavish/`, where `<git-dir>` is
  `git rev-parse --absolute-git-dir`). Otherwise save it in `.lavish/` in the
  working directory. Name it `ticket-<KEY>.html`.
- Never commit the page.
- Open it with `npx -y lavish-axi <file>` and poll with an `--agent-reply` that
  says which section to read first, usually the Status section when it has open
  questions.
- When the user annotates a passage, rewrite it in place in plainer words, with
  an example. Put the answer to a question on the page next to the passage.
  Save, then poll again with a one-line `--agent-reply`.

## 6. Reply in chat: short

The page holds the depth. The chat reply is five lines or fewer:

1. The ticket in one sentence.
2. Why it exists, in one sentence.
3. The open questions from the Status section, one line each, or "none".
4. The page path and the design source.

When the user asks a follow-up question in chat, answer in a few lines. Point
to the page section for the details, and add the answer to the page when it
is a lasting fact about the ticket.
