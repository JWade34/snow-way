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

## Measurement (automatic, in the app)
- Each change is compared 28 days before vs after, against untouched pages in the same section. Worse → reverted automatically
  (title/description) or flagged `needs_review` (content: revert the commit). Results show in /admin/changes and the Monday email.

## Monthly
- ChatGPT citation check (same five questions, `docs/geo-checks/`). Note who gets cited and why.
- Review slipping pages and seasonal timing (e.g. Southern Hemisphere guides before June, opening dates in October).
