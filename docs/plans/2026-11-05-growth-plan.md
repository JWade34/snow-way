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
- All of the above shipped 11/5 (commit b3d6c7b)
- Free Powder Calendar PDF lead magnet at /powder-calendar, instant token-gated download, subscribers tagged `powder-calendar` (commit 963ce2a)

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

## Phase 4: broader snow sports (decided 2026-11-05)
Keyword data (US/mo, peak, KD):
- [resort] weather: park city 74K, vail/breckenridge/mammoth 60.5K, KD 0-4 → shipped as mountain weather on resort pages
- [state] snow forecast: colorado 6.6K ($8.80 CPC), tahoe 6.6K (27K), utah 2.4K, KD 37-45 → add Tahoe + Summit County region groups, "forecast" in state titles
- [resort] webcam (breck 14.8K, vail 8.1K, KD 0), trail map (4-5K, KD 21), lift tickets (5.4K, KD 26) → official-link research per resort
- ski resorts near me 74K (201K peak) → geolocation page
- Winter adventures: snowmobiling 90.5K (KD 17), snow tubing near me 60.5K (246K peak, KD 7), snowshoeing 60.5K (KD 0), cross-country skiing 40.5K (KD 29) → topic hub + guides (in progress)
- Gear: heated jacket 60.5K (201K peak, KD 6), snow boots women 49.5K, best snow boots 4.4K (KD 3), ski rack 2.9K, roof box 2.9K → guides (in progress)
- Backcountry: splitboard 9.9K, backcountry skiing 8.1K, avalanche beacon 5.4K, KD 0-9 → careful safety-first guides
- International: niseko 14.8K, skiing in japan 5.4K, alps 4.4K ($3.63), heli skiing 2.9K ($6.39), valle nevado 9.9K (22K Jul), chile/argentina 2.9K each, south america ski resorts 1.6K → worldwide resorts (needs hemisphere-aware rankings; site copy says "North American")
- Where to stay in [resort] (vail hotels 18.1K) → with Justin's local takes + Stay22
