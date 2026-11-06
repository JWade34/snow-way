# Snow Way growth plan (SEO / GEO / AEO + affiliate)

Goal: own "where is the snow" search and AI answers for North American skiing, and earn from trip and gear intent.
Season peaks Dec–Feb, so everything in Phase 1 ships by mid-November.

## Done (2026-11-05)
- Resort forecast pages (89), state directories (24), city hubs (18), best-time pages (89), where-is-it-snowing,
  Ikon vs Epic, opening dates, 5 guides, widget, IndexNow, OG images, llms.txt, 100/100/100/100 Lighthouse.
- Sourced 2026-27 pass/opening/price facts in db/resort_facts.yml.

## Phase 1: build (Claude, now)
| # | Item | Target query (US/mo, peak) | Status |
|---|------|----------------------------|--------|
| 1 | Snowboard size calculator + chart | snowboard size chart 22.2K (74K) | shipped 11/5 |
| 2 | Ski size calculator + chart | ski size/length chart 9.9K+9.9K (27K) | shipped 11/5 |
| 3 | Epic Pass resorts page (live snow) | epic pass resorts 12.1K (27K) | shipped 11/5 |
| 4 | Ikon Pass resorts page (live snow) | ikon pass resorts 12.1K (22K) | shipped 11/5 |
| 5 | Weekly Powder Report (dated, archived) | AEO freshness, news pitches | shipped 11/5 |
| 6 | Powder alert signup (collect list now, send when email is set up) | retention | shipped 11/5 |
| 7 | About page + Organization schema | entity / E-E-A-T | shipped 11/5 |
| 8 | Affiliate plumbing: Stay22 map, gear links via AvantLink, rel=sponsored, disclosure page | revenue | shipped 11/5 |
| 9 | Articles: how to snowboard (6.6K), skiing vs snowboarding (1.6K), how to wax skis (1.3K) | shipped 11/5 |
| 10 | "How to choose" gear guides: gloves 4.4K, goggles 5.4K, helmet 3.6K, snowboard 2.9K, all-mountain skis 2.4K, ski boots 2.4K, base layer 1.3K, ski pants 1.3K | revenue | shipped 11/5 |

Rule for gear content: "how to choose" guides only. No "we tested" claims unless Justin actually tested the item.

## Phase 1b (in progress 11/5)
- Resort + state pages retargeted to "[resort] snow report" (12–27K/mo each vs ~3K for "forecast") with summit conditions — shipped
- 13 more articles: goofy vs regular (1.6K), camber vs rocker (1.5K), bibs vs pants, gloves vs mittens, balaclava vs ski mask (720), freestyle vs freeride, snowboard boots (2.9K + women's 2.9K), bindings (1.9K), ski socks (1.9K), snowboard jacket, snowboard pants, best snowboard brands (5.4K), best ski brands (2.4K)
- Finding: brand-vs-brand queries are tiny (10–110/mo); concept comparisons and "best brands" carry the volume.
- Outreach drafts: docs/outreach/templates.md

## Phase 2: Justin (accounts and outreach)
- [ ] Stay22 account → set STAY22_AID on Railway (lodging map turns on automatically)
- [ ] AvantLink account → apply to REI + evo → set AVANTLINK_WEBSITE_ID, AVANTLINK_REI_MID, AVANTLINK_EVO_MID
- [ ] Expedia Group creator account (hotel links)
- [ ] Email Ski Butlers / Black Tie for referral deals
- [ ] Email provider (Resend or Postmark) → Claude wires up powder alert sending
- [ ] Wikidata item for Snow Way (see superdupr docs/seo/wikidata-setup.md pattern)
- [ ] Weekly: post the Powder Report to r/skiing / regional subs; pitch the top-3 to local news (drafts in docs/outreach/)
- [ ] Widget outreach to ski clubs, lodges, rental shops

## Phase 3: compounding (Dec–Mar)
- Add Indy Pass resorts (indy pass resorts 5.4K, $8 CPC) once resort list is expanded
- "Best ski resorts in Colorado/Utah" ranked pages (6.6K / 2.4K) from data
- Paid alerts tier ($3–5/mo) once the list is meaningful
- End-of-season "most snow 2026-27" data report for backlinks
- Monthly: GSC queries review, AI-mention check (DataForSEO LLM mentions), refresh pass facts and prices
