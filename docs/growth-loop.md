# Weekly growth loop (Claude runbook)

Goal, in this order: (1) new traffic, clicks and AI citations through SEO, GEO and AEO, then (2) page changes that turn
that traffic into email signups and affiliate clicks. Rules from Justin: only make moves that improve a page, never regress
what already works, and every change must look solid on a phone and a desktop (`docs/ux-checklist.md`).

## Inputs
- `GET https://snowway.app/admin/loop.json` with `Authorization: Bearer $LOOP_API_TOKEN`: 28-day page stats, the guard verdict per page,
  queries per page, content gaps, the change ledger, plus:
  - `conversion`: pages with 15+ search clicks in 28 days that convert below the site average, ranked by missed signups
    and affiliate clicks (rates are per 100 search clicks, our visit proxy).
  - `citation_gaps`: questions from the latest AI citation check that no engine cited Snow Way for, with the sites cited instead.
- The Monday email / `/admin/growth` for the human view.

## Every Monday
1. Read loop.json. Skip pages whose `guard` is `blocked` (too little data, or a change is already being measured).
   A page takes one change at a time, so pick one change per page (a title and a description on the same page: the
   second one gets skipped).
2. **SEO (up to 5 changes), highest expected gain first:**
   - **Opportunity pages** (position 4–15, low CTR): rewrite the title and/or description to match the queries the page actually gets
     (see `page_queries`). Keep titles ≤70 chars, descriptions 50–160, unique, answer-first, no clickbait, "| Snow Way" suffix.
     Keep the page's main topic word in the title (a brands page keeps "brands").
   - **Content gaps**: a query with impressions where we rank >10. Improve the matching page (add a section, FAQ, internal link) or
     propose a new page if nothing fits. Content edits are code commits; log them as `kind: content`.
3. **AI citations (up to 2 changes)** from `citation_gaps`. Find the page that should answer the question (or note that none
   does). Make it the easiest page to quote: a 1–2 sentence direct answer at the top, the key numbers in a small table with
   sources, the question as an FAQ entry (FAQPage markup comes from the `faqs` local), and a dated "Updated" line. Look at what
   the cited sites have that we don't (a number, a comparison, a list) and add it only if we can source it. Log as `kind: content`.
4. **Conversion (up to 2 changes)** from `conversion.pages`, highest score first. Run `bin/ux-check --base https://snowway.app <path>`
   to see where the email box and affiliate links sit. Typical fixes: an email box (existing partial) right after the short answer
   when the only one is at the bottom of a long page; an affiliate link next to the sentence that recommends the product; a clearer
   button label. One move per page, never a pop-up, never weaken an existing call to action. Log as `kind: content`.
5. **Who decides:** content and conversion edits go live on deploy, so check the page's `guard` first.
   - `auto`: commit to main.
   - `approval` (winner or high traffic): don't touch main. Push a branch `claude/proposal-YYYY-MM-DD-<slug>` with the change and the
     before/after screenshots under `docs/proposals/YYYY-MM-DD/`, and list it in the summary. When Justin OKs it, merge, and add the
     ledger entry with `approved: true`.
6. Write title/description proposals and `kind: content` ledger entries to `db/seo_proposals.yml` (path, kind, value, reason).
   The deploy applies them through ChangeGuard: low-traffic pages go live automatically; winners and high-traffic pages wait for
   Justin in /admin/changes.
7. **UX gate:** for every page a code change touches, run `bin/ux-check --serve <paths>` and review the screenshots against
   `docs/ux-checklist.md`. Any FAIL, or a screenshot that looks worse than before, means fix it or drop the change.
8. Run `bin/rails test` (the SEO guard checks titles, descriptions, links). Commit and push only if green and the UX gate passed.
9. Never touch a page marked `winner` without a proposal Justin approves. Never change rankings, prices, or facts without a source.
10. **October 15 to December 31 only: refresh opening dates.** In `db/resort_facts.yml`, check every resort that is not `opened` and
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
  The UX gate (step 7) applies.
- Both need `LOOP_API_TOKEN` in the routine's cloud environment (Default). Without it they stop and change nothing.

## Routine IDs
- Monday loop: trig_01TNEf8zpaYbCiH79Ph4v9ru · Thursday (Dec–Feb): trig_01TDn5xU3nK2f8EGKGe2tH8V
- One-off pass price + opening status recheck, 2026-11-16: trig_01WwRgiDJ5qhUJHRLAwtX3QT
- All run in the Default environment with no connectors. Check a run: RemoteTrigger list_runs → get_run_log.
