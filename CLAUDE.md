# Snow Way (snowway.app)

Rails 8.1 ski snow-forecast site. Railway deploys every push to main.

## Goal, in this order
1. New traffic, clicks and AI citations (SEO, GEO, AEO).
2. Turn that traffic into email signups and affiliate clicks.

Only ship changes that improve a page. Never regress what already works.

## Every change that touches a page
- **UX gate:** run `bin/ux-check --serve <changed paths>` and review the screenshots against `docs/ux-checklist.md`. A FAIL, or a page
  that looks worse than before, blocks the push. Phones first: most visitors are on phones.
- Run `bin/rails test`. Push only when it's green. Don't run two test suites at once (SQLite locks).
- Facts, prices, dates and rankings change only with a fetched, cited source.
- Pages that are winners or high traffic (loop.json `guard: approval`) need Justin's OK before their content changes.

## Where things are
- Weekly growth loop runbook: `docs/growth-loop.md` (data feed: `/admin/loop.json`).
- Session handoff (local only, not in git): `RESUME-HERE.md`. Justin's task list: `docs/JUSTIN_TODO.md`.
- Writing style: short, plain sentences, no em dashes.
