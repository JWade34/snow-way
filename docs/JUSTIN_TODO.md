# Justin's to-do list for Snow Way

Claude keeps this file current. Newest items at the top of each section. Check things off as you go.
Last updated: 2026-11-06

## Do now (highest payoff first)

- [ ] **Resorts you've ridden (2 minutes, no writing).** snowway.app/admin → **Resorts I've ridden** → check them all off. Then whenever you have 5 minutes, **Paste / dictate** one resort per line ("Alta: skiers only, best snow in Utah."; lines starting with "-" become tips). Open each draft, fix it, check **Publish**. Start with Vail, Breckenridge, Park City, Mammoth, Jackson Hole, Whistler. First-hand takes are the one thing no competitor can copy.
- [ ] **AvantLink: website verified, in staff review (2026-11-06).** When approved, apply to evo, Backcountry and other ski shops inside it (REI is on Impact, skip it here) and send Claude your website ID plus each merchant ID. The Monday growth email lists every pending application until it is wired in.
- [ ] **Wikidata item for Snow Way** (10 minutes). Steps are in Claude's chat from 2026-11-06 (Special:NewItem, label Snow Way, instance of website, official website). Send Claude the Q-number. Helps Google and AI tools treat Snow Way as its own brand, separate from Sno-Way the plow company.
- [ ] **Snow Way profiles on Instagram and Reddit** (name "Snow Way", link to snowway.app, bio mentioning ski snow forecasts). Same reason: wins searches for our own name. Send Claude the URLs and they go in the site's schema.
- [ ] **REI (via Impact): application in review (submitted 2026-11-05).** When approved: create a link, add it on Railway as `REI_IMPACT_LINK` (or send it to Claude). If declined, reapply once Search Console shows traffic.

## When you have time

- [ ] **Amazon Associates** (affiliate-program.amazon.com). About 3%, good for small stuff (hand warmers, wax, socks). Add the tag on Railway as `AMAZON_ASSOCIATE_TAG` or send it to Claude. Amazon closes accounts without 3 sales in 180 days (you can reapply), so do this after traffic picks up.
- [ ] **Discover Cars** (discovercars.com/affiliate). "Rent a 4x4" buttons are already on every resort page. Send Claude your ID.
- [ ] **Skyscanner** (via Impact). Lowest payout per click; do it last. Send Claude your link format.
- [ ] **Gear closet.** snowway.app/admin → Gear closet. Log what you own with private notes; check "Show on /what-i-ride" for anything you'd recommend. The public page appears once one item is public.
- [ ] **Send Claude your real tips** (voice memo transcripts or bullets): Vail local tips, South America trip (resort pages and the Chile/Argentina guide are waiting; that traffic peaks June to September), family and first-trip advice.
- [ ] **Backcountry guides need your eye.** Read /guides/backcountry-skiing, /guides/splitboarding, /guides/avalanche-safety-gear. One or two lines from you would make them stronger. If anything feels off on safety, tell Claude and it comes down.
- [ ] **Confirm photo rights.** The night snowstorm shot and the Mammoth Lakes sign look professionally shot. Tell Claude a name for credit, or say "remove".
- [ ] **Rental delivery partners.** Email Ski Butlers and Black Tie Ski Rentals using template 4 in `docs/outreach/templates.md`.
- [ ] **A few skiing (not snowboarding) photos**, plus any at recognizable resorts.

## Every week (Thursday)

- [ ] Open snowway.app/powder-report (a new snapshot is archived every Thursday at 7am MT).
- [ ] Post it to one or two subreddits (template 1). Rotate: r/skiing, r/snowboarding, r/COsnow, r/skiing_utah, r/icecoast.
- [ ] Pitch the week's top resorts to two or three local outlets in the snowiest region (template 2).
- [ ] Send the widget pitch to five ski clubs, lodges, or rental shops (template 3).

## Every month

- [ ] Google Search Console → Performance: note top queries and pages; tell Claude about any surprises.
- [ ] Ask Claude to "run the ChatGPT citation check" (same five questions each month; baseline in `docs/geo-checks/2026-11-06.md`: not cited yet, as expected for a new site).
- [ ] Bing Webmaster Tools → IndexNow report: confirm submissions are succeeding (Claude submitted all 270 URLs manually on 11/5, HTTP 200; new URLs now submit automatically on every deploy).

## Done
- [x] Growth tracking (2026-11-06): Google Search Console connected, daily sync, affiliate clicks and signups tracked by page, admin Growth tab, Monday 7am report email
- [x] Admin password set; Google and Bing connected; growth loop scheduled (Mondays + peak-season Thursdays) with its key in the Default cloud environment (2026-11-06)
- [x] Private admin (2026-11-06): resorts-ridden checklist, dictate/paste importer, gear closet, subscriber list with CSV download
- [x] International "snow around the world" section on where-is-it-snowing; Chamonix and La Parva elevations corrected (2026-11-06)
- [x] Tested the welcome email and Powder Calendar (2026-11-06)
- [x] Worldwide (2026-11-05): 35 international resorts (Japan, the Alps, Chile, Argentina, Australia, New Zealand), country pages, and Skiing in Japan / the Alps / Chile and Argentina guides
- [x] Phase 4 shipped (2026-11-05): Lake Tahoe, Summit County, and Southern California region pages; "ski resorts near me" page (location stays in the browser); backcountry skiing, splitboarding, and avalanche safety gear guides
- [x] Stay22 set up (AID `snowway`); lodging map live on all resort pages (2026-11-05)
- [x] Mailing address for email footers (Fast City LLC, Austin) — added to every email (2026-11-05)
- [x] Summit vs mid-mountain: show both, mid-mountain headline (2026-11-05)
- [x] Resend account, API key on Railway, DNS verified (2026-11-05). Welcome emails and powder alerts are live.
- [x] Sent snow photos (2026-11-05)
- [x] Tested the Powder Calendar download in production (2026-11-05)
- [x] Submitted sitemap to Google Search Console and Bing (2026-11-05)

---

## Affiliate programs: what each pays and where the links go

Rates and terms come from third-party directories unless marked official. Confirm them in each dashboard when you're approved.

| Program | Network / how to join | What you earn | How you get paid | Where it shows on the site | Turns on with |
|---|---|---|---|---|---|
| **Stay22** (hotels, Airbnb-style rentals) | stay22.com | Share of the booking site's commission (Stay22 says it starts at 30%); bloggers report about $6–11 per booking | Via Tipalti. PayPal, direct deposit, or eCheck once you reach $100; wire at $500. You request a payout monthly | Lodging map on every resort page, under "Book Your Trip" | `STAY22_AID` (no code needed) |
| **REI** | AvantLink | About 5%, 15-day cookie | AvantLink pays monthly via Tipalti (ACH, PayPal, or international transfer) after the merchant pays; reported $25 minimum | All gear links in guides and size calculators | `AVANTLINK_WEBSITE_ID` + `AVANTLINK_REI_MID` (no code needed) |
| **evo** | AvantLink | About 5%, 30-day cookie | Same as REI | Added alongside REI | Tell Claude once approved |
| **Other ski shops** (UtahSkis, The Peak, Sun & Ski, Christy) | AvantLink / own programs | Listed at about 7–10% | Varies | Brand guides and gear guides | Tell Claude which approve |
| **Skyscanner** (flights) | Impact | Reported 20–50% of Skyscanner's revenue per booking; low per click | Impact pays monthly; reported $50 minimum | "Flights" button on resort pages | Tell Claude your link format |
| **Discover Cars** (rental cars) | Direct or Travelpayouts | Reported as a share of Discover Cars' profit per rental; long cookie | Monthly, PayPal or wire; reported $200 minimum | "Rent a 4x4" button on resort pages | Tell Claude your ID |
| **Amazon Associates** | Amazon | About 3% for sports and outdoors | Monthly direct deposit or gift card | Small accessories in guides | Tell Claude your tag |
| **Ski Butlers / Black Tie** | Direct outreach | Negotiated | Negotiated | Resort pages in their delivery areas | After a deal |

**How the money flows:** someone reads a snow report or a guide → clicks a lodging, gear, flight, or car link → books or buys within the cookie window → the program records your commission → it's approved after the stay or the return window → paid monthly once you pass the minimum. Lodging is usually the biggest earner per click (multi-night ski-town stays); gear brings steady small amounts.

**Rules Claude follows for every link:** marked `rel="sponsored"`; affiliate guides carry a disclosure at the top; snow rankings are never paid; no "we tested" claims.
