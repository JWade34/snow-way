# Justin's to-do list for Snow Way

Claude keeps this file current. Newest items at the top of each section. Check things off as you go.
Last updated: 2026-11-05

## Do now (highest payoff first)

- [ ] **REI (via Impact).** Site verification tag is live on snowway.app; click **Add Website / Verify** in Impact, then apply to REI. Once approved, copy your REI **tracking link** from Impact (looks like `https://rei.xxxx.net/c/1234567/123456/12345`) and add it on Railway as `REI_IMPACT_LINK`. Every gear link then tracks.
- [ ] **Amazon Associates (optional, good for accessories).** affiliate-program.amazon.com → add your tag on Railway as `AMAZON_ASSOCIATE_TAG` (e.g. `snowway-20`). If REI is also live, accessories go to Amazon and core gear to REI automatically. Note: Amazon closes accounts without 3 sales in the first 180 days (you can reapply).
- [ ] **AvantLink (evo, Backcountry, Christy Sports).** Optional extra shops; tell Claude when one approves.
- [ ] **"What I ride" list.** Your actual board, boots, bindings, goggles, jacket, and what you think of each. Real gear reviews from a former shop owner rank where generic roundups don't; Claude builds the page.
- [ ] **Test the emails:** sign up yourself at snowway.app/powder-calendar (use a different email than before). You should get the welcome email with the download link within a minute.

## Your expertise (the biggest edge no competitor can copy)

- [ ] **Fill in `docs/locals-take-template.md`** (Colorado, Utah, California, and Nevada resorts listed, with 4 quick prompts each; skip any you haven't ridden). Or just dictate: "Alta: ..." works. Each one becomes a "Local's take" box on that resort's page. The box design is built and waiting.
- [ ] **Send Claude your real tips, as voice memo transcripts or bullet notes.** Google and AI tools reward first-hand experience, and you lived in Vail and have ridden all over North and South America. Claude will add a "Justin's take" box to the matching resort pages, guides, and the Trip Planner PDF. Ideas:
  - Vail local tips: best days and times, where locals go on a powder day, parking, how you'd spend a 3-day trip
  - Resorts you've ridden (name each one) plus one honest line apiece: who it's for, what to skip
  - South America: which resorts, when to go, how the trip works (Claude can also add Southern Hemisphere resorts, which bring in traffic June to September when North America is quiet)
  - Your best family-trip and first-trip advice
- [ ] **Confirm photo rights.** The night snowstorm shot and the Mammoth Lakes sign look professionally shot. If a friend or photographer took them, tell Claude their name for a photo credit (or say "remove" and they'll come down).

## Decisions for you

- [x] **Summit vs mid-mountain forecasts.** Decided 11/5: mid-mountain is the big number, summit underneath. Shipped.
- [ ] ~~old~~ Snow Way forecasts at each resort's summit, which shows more snow than the mid-mountain numbers other sites use (this week: Whistler ~50" on Snow Way vs ~25" quoted by ChatGPT from j2ski). Summit is accurate for the top of the mountain and is labeled, but it can look inflated next to competitors. Options: keep summit (current), switch to mid-mountain, or show both. Claude recommends showing both, with mid-mountain as the headline number.

## This week

- [ ] **Skyscanner (flights) via Impact.** Sign up at impact.com, apply to Skyscanner. Send Claude your tracking link format; it'll swap the Kayak flight buttons on resort pages.
- [ ] **Discover Cars (4x4 rentals).** Apply at discovercars.com/affiliate (or via Travelpayouts). Send Claude your affiliate ID; it'll swap the "Rent a 4x4" buttons.
- [ ] **Amazon Associates (small gear: hand warmers, wax kits, balaclavas, socks).** Optional. Sign up at affiliate-program.amazon.com and send Claude your tag.
- [ ] **Rental delivery partners.** Email Ski Butlers and Black Tie Ski Rentals using template 4 in `docs/outreach/templates.md`.
- [ ] **Wikidata item for Snow Way.** Create an item (instance of: website; official website: https://snowway.app; founder: Justin McKelvey). This helps Google and AI tools treat Snow Way as a known entity.

## Nice to have

- [ ] **A few skiing (not snowboarding) photos**, plus any with recognizable resorts (Vail, Mammoth, Heavenly, South America). Claude matches them to guides and resort pages. Already used: 11 photos (cabin roof rail, chairlift storm selfie, powder jump, night storm, Mammoth sign, sitting above the valley, canyon selfie, snowbank road, green-pants view, sunny selfie, tree trail). Skipped: your friend's selfie, the EpicMix screenshot, and the two quote images.

## Every week (Thursday)

- [ ] Open snowway.app/powder-report (a new snapshot is archived every Thursday at 7am MT).
- [ ] Post it to one or two subreddits (template 1). Rotate: r/skiing, r/snowboarding, r/COsnow, r/skiing_utah, r/icecoast.
- [ ] Pitch the week's top resorts to two or three local outlets in the snowiest region (template 2).
- [ ] Send the widget pitch to five ski clubs, lodges, or rental shops (template 3).

## Every month

- [ ] Google Search Console → Performance: note top queries and pages; tell Claude about any surprises.
- [ ] Bing Webmaster Tools → IndexNow report: confirm submissions are succeeding (Claude submitted all 270 URLs manually on 11/5, HTTP 200; new URLs now submit automatically on every deploy).

## Done
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
