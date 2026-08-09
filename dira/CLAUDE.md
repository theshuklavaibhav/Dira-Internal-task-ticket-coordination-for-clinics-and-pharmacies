# Agent Instructions — Dira

## Constraints I actually care about
- Stay on free-tier infrastructure unless I explicitly say otherwise. If something
  needs Blaze/a paid plan, tell me that up front and give me the free alternative
  first (Cloudflare Workers instead of Cloud Functions, EmailJS instead of a mail
  server, etc).
- Never put a secret key, REST API key, or service account credential in client-side
  Dart code, even behind --dart-define. If a feature needs a secret, it needs a
  server-side piece (Worker), not a client one. Flag it if I ask for something that
  would break this.

## How I want debugging handled
- Don't guess-and-check. When something breaks, find the actual root cause (check
  logs, check Firestore console, check the deployed rules vs the local file) before
  proposing a fix. I'd rather wait 2 extra minutes for the real answer than try 5
  wrong fixes.
- If a fix touches security rules or Firestore write ordering, explain *why* the
  ordering matters, not just what to paste.

## How to give me instructions
- Number the steps. Tell me exactly which terminal/folder/file each command goes in.
- If a command could break something else in the project, say so before I run it.
- Don't tell me "done" until we've actually tested it — assigning a ticket and
  confirming the other account got notified, not just "the code should now work."

## What NOT to do
- Don't paste real secrets back into chat even if I do first — flag it and tell me
  to rotate it.
- Don't assume I want the "proper enterprise" solution by default — ask first if a
  simpler free option exists, especially for anything auth/billing/infra related.