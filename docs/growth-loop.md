# Weekly growth loop (Claude runbook)

Goal: more search traffic (Google, Bing, AI answers), then email signups and affiliate clicks.
Rule from Justin: only make moves that improve a page. Never regress what already works.

## Inputs
- `GET https://snowway.app/admin/loop.json` with `Authorization: Bearer $LOOP_API_TOKEN`: 28-day page stats, the guard verdict per page,
  queries per page, content gaps, and the change ledger.
- The Monday email / `/admin/growth` for the human view.

## Every Monday
1. Read loop.json. Skip pages whose `guard` is `blocked` (too little data, or a change is already being measured).
2. Pick at most 5 changes, highest expected gain first:
   - **Opportunity pages** (position 4–15, low CTR): rewrite the title and/or description to match the queries the page actually gets
     (see `page_queries`). Keep titles ≤70 chars, descriptions 50–160, unique, answer-first, no clickbait, "| Snow Way" suffix.
   - **Content gaps**: a query with impressions where we rank >10. Improve the matching page (add a section, FAQ, internal link) or
     propose a new page if nothing fits. Content edits are code commits; log them as `kind: content`.
   - **Pages with signups or affiliate clicks**: never weaken their calls to action.
3. Write title/description proposals to `db/seo_proposals.yml` (path, kind, value, reason). The deploy applies them through
   ChangeGuard: low-traffic pages go live automatically; winners and high-traffic pages wait for Justin in /admin/changes.
4. Run `bin/rails test` (the SEO guard checks titles, descriptions, links). Commit and push only if green.
5. Never touch a page marked `winner` without a proposal Justin approves. Never change rankings, prices, or facts without a source.
6. **October 15 to December 31 only: refresh opening dates.** In `db/resort_facts.yml`, check every resort that is not `opened` and
   whose `opening_date` is past or within 7 days, plus big names with no date yet. Mark `opened` (with the real opening day) or move
   the date only when a fetched source confirms it: the resort's own site or press release, the Vail Resorts or Alterra newsroom,
   or dated local news. Unconfirmed entries stay as they are. Never use a URL you did not fetch. Set `checked_on` only when the pass
   prices in the same file were re-verified too; otherwise leave it.

## Measurement (automatic, in the app)
- Each change is compared 28 days before vs after, against untouched pages in the same section. Worse → reverted automatically
  (title/description) or flagged `needs_review` (content: revert the commit). Results show in /admin/changes and the Monday email.

## Monthly
- ChatGPT citation check (same five questions, `docs/geo-checks/`). Note who gets cited and why.
- Review slipping pages and seasonal timing (e.g. Southern Hemisphere guides before June, opening dates in October).

## Schedule (cloud routines, claude.ai/code/routines)
- **Mondays 15:00 UTC** (8am Mountain in winter), after the 7am email: the full loop above.
- **Thursdays 15:00 UTC, December–February only**: add-only. New FAQ answers, sections, internal links or guides for
  queries that took off that week. Never edits existing titles, descriptions or copy, and never touches seo_proposals.yml.
- Both need `LOOP_API_TOKEN` in the routine's cloud environment (Default). Without it they stop and change nothing.

## Routine IDs
- Monday loop: trig_01TNEf8zpaYbCiH79Ph4v9ru · Thursday (Dec–Feb): trig_01TDn5xU3nK2f8EGKGe2tH8V
- One-off pass price + opening status recheck, 2026-11-16: trig_01WwRgiDJ5qhUJHRLAwtX3QT
- All run in the Default environment with no connectors. Check a run: RemoteTrigger list_runs → get_run_log.
