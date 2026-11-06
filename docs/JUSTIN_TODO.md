# Justin's to-do list for Snow Way

Claude keeps this file current. Newest items at the top of each section. Check things off as you go.
Last updated: 2026-11-05

## Do now (highest payoff first)

- [ ] **Stay22 (lodging map).** Sign up at stay22.com → copy your affiliate ID (AID) → Railway → snow-way service → Variables → add `STAY22_AID=<your id>` → redeploy.
  A lodging map then appears on all 89 resort pages automatically.
- [ ] **AvantLink + REI (gear links).** Sign up at avantlink.com as an affiliate (website: snowway.app) → apply to REI (and evo, Backcountry, Christy Sports while you're there) → once REI approves, find your **Website ID** and **REI Merchant ID** → add `AVANTLINK_WEBSITE_ID` and `AVANTLINK_REI_MID` on Railway.
  Every gear link across the 29 guides and both size calculators starts tracking. Tell Claude when evo approves and it'll add evo links.
- [ ] **Email service for powder alerts.** Resend (resend.com) or Postmark. Verify the snowway.app domain (they'll give you DNS records), create an API key, add it on Railway as `RESEND_API_KEY` (or `POSTMARK_API_TOKEN`), and tell Claude. Alerts and a welcome email get switched on for everyone already on the list.
- [ ] **Test the Powder Calendar in production.** Go to snowway.app/powder-calendar, enter your email, and download the PDF. (Claude tested locally; it skipped production so test emails wouldn't land in your real list.)

## Decisions for you

- [ ] **Summit vs mid-mountain forecasts.** Snow Way forecasts at each resort's summit, which shows more snow than the mid-mountain numbers other sites use (this week: Whistler ~50" on Snow Way vs ~25" quoted by ChatGPT from j2ski). Summit is accurate for the top of the mountain and is labeled, but it can look inflated next to competitors. Options: keep summit (current), switch to mid-mountain, or show both. Claude recommends showing both, with mid-mountain as the headline number.

## This week

- [ ] **Skyscanner (flights) via Impact.** Sign up at impact.com, apply to Skyscanner. Send Claude your tracking link format; it'll swap the Kayak flight buttons on resort pages.
- [ ] **Discover Cars (4x4 rentals).** Apply at discovercars.com/affiliate (or via Travelpayouts). Send Claude your affiliate ID; it'll swap the "Rent a 4x4" buttons.
- [ ] **Amazon Associates (small gear: hand warmers, wax kits, balaclavas, socks).** Optional. Sign up at affiliate-program.amazon.com and send Claude your tag.
- [ ] **Rental delivery partners.** Email Ski Butlers and Black Tie Ski Rentals using template 4 in `docs/outreach/templates.md`.
- [ ] **Wikidata item for Snow Way.** Create an item (instance of: website; official website: https://snowway.app; founder: Justin McKelvey). This helps Google and AI tools treat Snow Way as a known entity.

## Every week (Thursday)

- [ ] Open snowway.app/powder-report (a new snapshot is archived every Thursday at 7am MT).
- [ ] Post it to one or two subreddits (template 1). Rotate: r/skiing, r/snowboarding, r/COsnow, r/skiing_utah, r/icecoast.
- [ ] Pitch the week's top resorts to two or three local outlets in the snowiest region (template 2).
- [ ] Send the widget pitch to five ski clubs, lodges, or rental shops (template 3).

## Every month

- [ ] Google Search Console → Performance: note top queries and pages; tell Claude about any surprises.
- [ ] Bing Webmaster Tools → IndexNow report: confirm submissions are succeeding.

## Done
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
