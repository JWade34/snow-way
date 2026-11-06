# Justin's to-do list for Snow Way

Claude keeps this file current. Newest items at the top of each section. Check things off as you go.
Last updated: 2026-11-06

## Do now (highest payoff first)

- [ ] **Turn on your private admin area (2 minutes).** Pick a password (12+ characters) and run this in Claude Code: `! railway variables --service snow-way --set "ADMIN_PASSWORD=your-password-here"`. Railway redeploys; then open snowway.app/admin (user: `justin`). Save it in your phone's browser. Until the password is set, /admin returns "not found".

- [ ] **REI (via Impact): application in review (submitted 2026-11-05).** When approved: Impact → Manage → My Brands → REI → Create Link, copy the tracking link (`https://rei.xxxx.net/c/...`), add it on Railway as `REI_IMPACT_LINK` (or send it to Claude). If declined, reapply once Search Console shows traffic.
- [ ] **Affiliate sign-ups, in order of what they'll earn** (Stay22 lodging is already live and is the biggest earner per click):
  1. **AvantLink** (avantlink.com, apply as a publisher; then apply to evo, Backcountry, and REI inside it). One account covers most ski shops at about 5–8%. Send Claude your website ID and each merchant ID once approved.
  2. **Amazon Associates** (details below). Easy approval, about 3%, converts well on small stuff.
  3. **Discover Cars** (discovercars.com/affiliate). Ski trips mean 4x4 rentals; the "Rent a 4x4" buttons are already on every resort page.
  4. **Skyscanner** (via Impact). Lowest payout per click; do it last.
- [ ] **Amazon Associates (optional, good for accessories).** affiliate-program.amazon.com → add your tag on Railway as `AMAZON_ASSOCIATE_TAG` (e.g. `snowway-20`). If REI is also live, accessories go to Amazon and core gear to REI automatically. Note: Amazon closes accounts without 3 sales in the first 180 days (you can reapply).
- [ ] **AvantLink (evo, Backcountry, Christy Sports).** Optional extra shops; tell Claude when one approves.
- [ ] **Gear closet.** snowway.app/admin → Gear closet. Log everything you own (riding now, quiver, retired, wishlist) with private notes. Check "Show on /what-i-ride" for anything you'd recommend; the public page appears once one item is public. Private notes never show.

## Your expertise (the biggest edge no competitor can copy)

- [ ] **Your resorts, the easy way** (replaces the template file):
  1. snowway.app/admin → **Resorts I've ridden** → check off every resort you've ridden (about 2 minutes, no writing).
  2. Whenever you have 5 minutes: **Paste / dictate** on your phone, tap the keyboard mic, and talk one resort per line ("Alta: skiers only, best snow in Utah."). Lines starting with "-" become tips for the resort above. Or keep a running note in Apple Notes and paste it in.
  3. Open each draft, fix anything, check **Publish**. It shows as "Local's take" (Colorado and Utah) or "Justin's take" (everywhere else) on that resort's page and gets listed on your author page.
  Start with the big ones: Vail, Breckenridge, Park City, Mammoth, Jackson Hole, Whistler.
- [ ] **Send Claude your real tips, as voice memo transcripts or bullet notes.** Google and AI tools reward first-hand experience, and you lived in Vail and have ridden all over North and South America. Claude will add a "Justin's take" box to the matching resort pages, guides, and the Trip Planner PDF. Ideas:
  - Vail local tips: best days and times, where locals go on a powder day, parking, how you'd spend a 3-day trip
  - Resorts you've ridden (name each one) plus one honest line apiece: who it's for, what to skip
  - South America: which resorts you rode, when you went, how the trip worked. The resort pages and the "Skiing in Chile and Argentina" guide are live and waiting for your take (that traffic peaks June to September)
  - Your best family-trip and first-trip advice
- [ ] **Backcountry guides need your eye.** You've ridden a lot of terrain, so read /guides/backcountry-skiing, /guides/splitboarding, and /guides/avalanche-safety-gear. If you tour or split, one or two lines from you (your setup, how you got started) would make them much stronger. If anything feels off on safety, tell Claude and it comes down.
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
- [ ] Ask Claude to "run the ChatGPT citation check" (same five questions each month; baseline in `docs/geo-checks/2026-11-06.md`: not cited yet, as expected for a new site).
- [ ] Bing Webmaster Tools → IndexNow report: confirm submissions are succeeding (Claude submitted all 270 URLs manually on 11/5, HTTP 200; new URLs now submit automatically on every deploy).

## Done
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
