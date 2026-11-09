# Snippet, PAA and AI Overview audit (November 2026)

Run 2026-11-08. SERPs: DataForSEO live advanced, United States, English, desktop, depth 10. Pages: fetched live from snowway.app the same day. Queries: the top 20 Search Console queries by impressions from `/admin/loop.json` (page_queries + query_gaps, 14-day window), plus 10 target queries. #20 was a tie at 8 impressions (best snowboard bindings, best healthiest snowboard, tremblant snow forecast, balaclava vs ski mask, all inclusive ski trips). I picked balaclava vs ski mask because its page already ranks around 6.

## What the audit found

1. **There is no featured snippet on any of the 30 SERPs.** Google has replaced them with AI Overviews: 21 of the 30 show one (17 loaded, 4 loaded asynchronously so their content didn't come through). The thing to win now is an AI Overview citation, plus PAA boxes where they still appear. Snippet "format matching" mostly means making our answer easy for the AI Overview to lift: a one-paragraph definition or answer, then a bulleted or tabled list.
2. **Snow Way isn't in the live top 10 for any of the 30 queries, and no AI Overview cites us.** Search Console averages (for example 5 to 9 for the brand guides, 1.7 for the snowboard pants long-tail) are blended over 14 days and many query variants. The live US desktop top 10 is different: for the head terms it's Reddit, Facebook, magazines and shopping carousels.
3. **Every page we checked has a `.tldr`.** The exceptions are the homepage and the resort pages (`/resorts/aspen-snowmass`, `/resorts/crystal-mountain`), which have none. Most tldrs run 52 to 69 words. The four `getting-there` pages and several list pages pad the `.tldr` with method notes ("Drive times are estimates from OpenStreetMap routing…", "Snow forecast updated Nov 8…"). That pushes them past 60 words and buries the answer. **Moving those notes out of the `.tldr` element is the single biggest template fix.**
4. **The AI Overviews on the travel-route queries pull the same facts we already publish** (miles, drive time, I-70 / CO-9, shuttles), but they cite Peak 1 Express, Epic Mountain Express, Summit Express, Bustang, gobreck.com, Reddit and Uber. Our pages lack PAA-shaped FAQs ("Is it difficult to drive…", "What is the best way to get…", "Is it better to fly into Vail or Denver?").
5. **The brand queries (`snowway`, `snow way`) are owned by Sno-Way, the snowplow maker.** Google offers no PAA we could answer on those SERPs. This is an entity problem, not a snippet one (see the homepage section).

Notes and raw extracts: the scratchpad `notes.md` / `notes2.md` from this session. Rules for every edit below: use only facts already on our pages, and invent no numbers.

---

## Part 1: Top 20 Search Console queries

### 1. what is the best snowboard (467 impr)
- **Our page:** `/guides/best-snowboard-brands` (GSC avg 7.4; 407 impr) and `/guides/best-snowboard` (6.1). **Live position:** not in top 11.
- **Featured snippet:** none. **AI Overview:** none on this SERP (popular-products carousel, video pack, Reddit, Slope Magazine list, Gear Institute).
- **PAA:** What type of snowboard should I get? · How do I maintain my snowboard? · Who are some of the best snowboarders? · How much is a really good snowboard?
- **Our page:** the tldr is 83 words (too long) and opens with "Short answer:". The picks table directly answers the query, which is good. The FAQs don't match these PAA questions. There's no "how much" FAQ, even though the table lists prices.
- **Edits:**
  - Rewrite the `/guides/best-snowboard-brands` tldr to 49 words: "The best snowboard for most riders in 2026-27 is the Salomon Highpath (about $700), Outside's top pick, with the CAPiTA Matriarch (about $730) close behind. Beginners should look at the Burton Cultivator (about $400). There's no single best board: pick one that matches your riding style, ability and weight." Move the reviewer list sentence below the tldr.
  - Add FAQ "How much is a really good snowboard?" answered from the table: "The top-rated 2026-27 boards list at about $550 to $750 (Salomon Highpath about $700, CAPiTA Matriarch about $730, Jones Flagship about $750); the top beginner picks list at about $400 to $450 (Burton Cultivator, Rossignol Evader). Prices are reviewers' list prices and vary by retailer and size."
  - Add FAQ "What type of snowboard should I get?" reusing the `/guides/best-snowboard` tldr: an all-mountain board with a medium flex, sized by weight first and height second.
  - Retitle the table's caption/H2 to "Best snowboards of 2026-27 by rider type" so the list reads cleanly as list-snippet material.

### 2. alternatives to rossignol (58)
- **Our page:** `/guides/best-ski-brands` (GSC 6.1). **Live:** not in top 10.
- **FS:** none. **AIO:** yes. It's a bulleted list of brands and models by ski type (Blizzard, Nordica, Atomic, Salomon, Elan), plus Tecnica Group. Cites Reddit, Facebook, trailsandfreedom, GearLab, POWDER, Powder7, skimag, CB Insights. **PAA:** none.
- **Our page:** we have FAQ "What are good alternatives to Rossignol skis?", but it sits at the bottom. The page has no dedicated alternatives list near the top.
- **Edits:** Add an H2 "Alternatives to Rossignol" directly under the tldr, with a 5-item bulleted list drawn from the brand facts already on the page (Völkl, Head, Atomic, Salomon, Blizzard/Nordica). Use one line per brand with its country and what we say it's known for (for example "Völkl (Germany): damp, stable skis that hold an edge on hard snow"). The AIO format is a brand-by-brand bulleted list, so mirror it.

### 3. what are the best ski brands (57)
- **Our page:** `/guides/best-ski-brands` (9.3). **Live:** not in top 12.
- **FS:** none. **AIO:** yes. It's a bulleted brand list split into "heritage" brands and "boutique" brands. Cites Reddit, Treeline Review, skimag, Newschoolers, Facebook, The Ski Monster.
- **PAA:** What are the best skis for intermediate to advanced skiers? · Where do billionaires go to ski? · Is Volkl a good ski brand? · What are the top 5 ski resorts?
- **Our page:** the tldr (52 words) says "there's no single best ski brand" without naming any brands. That gives the AIO nothing to lift. The brand table (maker / HQ / known for) sits about 18 headings down.
- **Edits:**
  - Change the tldr so it names brands, keeping it under 60 words: "Short answer: there's no single best ski brand, but the major makers are Rossignol, Salomon, Atomic, K2, Völkl, Head, Blizzard, Nordica, Elan and Fischer. Each sells skis for beginners, groomers and powder, so pick the one whose lineup fits how and where you ski." (These are the 10 brands the page covers, in page order.)
  - Move the brand-origin table up to directly under the tldr.
  - Add FAQ "Is Völkl a good ski brand?" answered from the page: family business making skis in Straubing, Bavaria since 1923, described as Germany's largest remaining ski manufacturer, suited to skiers who want a damp, stable ski on hard snow.

### 4. snowway (37) and 9. snow way (16)
- **Our page:** `/` (GSC 5.4 / 5.9). **Live:** not in top 10. Every result is Sno-Way (snowplows). An AIO is present (async). PAA for "snow way" is about plowing.
- **Our page:** the homepage has no `.tldr`. It has FAQ schema (4 questions).
- **Edits:** Add a 40 to 50 word `.tldr` under the H1 that states the entity clearly. Build it from the homepage's existing FAQ answers, for example: "Snow Way is a ski snow forecast site that ranks which ski resorts are getting the most snow this week…", then add the update frequency and data source exactly as the homepage FAQs state them. Make sure Organization/WebSite schema uses the name "Snow Way" with `alternateName: "SnowWay"` and `url: https://snowway.app`. This is an entity fix, not a snippet win, so it's lower priority.

### 5. apres ski (32)
- **Our page:** `/guides/what-is-apres-ski` (GSC 19.0). **Live:** not in top 11 (Dope Snow is #1).
- **FS:** none. **AIO:** yes. It opens with the definition "Après-ski (French for 'after skiing') refers to the social activities…". Cites AFAR, Columbia, Katie Kime, Peter Glenn, Reddit, Snowmass Mountain Lodging, Vail.
- **PAA:** What should I wear for après ski? · Where does Kate Middleton go skiing? · Is 4 days of skiing too much? · What are the best après ski places in Breckenridge?
- **Our page:** the tldr (69 words) has the right definition shape but runs long because it adds a drink-driving clause. FAQ "What do you wear to après-ski?" already matches PAA 1.
- **Edits:**
  - Trim the tldr to 52 words by moving the last sentence ("never drive mountain roads after drinking") into the body.
  - Add FAQ "What are the best après-ski places in Breckenridge?" using only what's on the page: Breckenridge Distillery's Main Street tasting room, and distillery tours that end with a bourbon tasting (21+). Link `/things-to-do-in-breckenridge-in-winter`.
  - Rename FAQ "What do you wear to après-ski?" to "What should I wear for après-ski?" (exact PAA wording).

### 6. ski brands (30)
- **Our page:** `/guides/best-ski-brands` (8.0). **Live:** not in top 11.
- **FS:** none. **AIO:** yes. It's a bulleted list, each brand with its country of origin. Cites Treeline Review, Wikipedia "List of ski brands" (a table of brand, type, origin and established year), POWDER, Colorado Ski Shop, SkiEssentials, evo.
- **PAA:** What brands do skiers wear? · Where do billionaires go to ski? · Is Bogner a good ski brand? · What's the difference between ski boots?
- **Our page:** our brand table has exactly the AIO's facts (HQ and founding year), but it sits low on the page.
- **Edits:** Same table move as #3. Add a "Founded" column if the year appears in each brand's section (Völkl's 1923 does). Link FAQ "What's the difference between ski boots?" to `/guides/best-ski-boots` rather than answering it here.

### 7. alternatives to burton (27)
- **Our page:** `/guides/best-snowboard-brands` (8.8). **Live:** not in top 10.
- **FS:** none. **AIO:** yes. It's a list by gear type (boards: Jones, CAPiTA, Nitro, YES, Lib Tech, GNU, Bataleon, Never Summer, Rome, Arbor; bindings: Union, Rome; boots: ThirtyTwo, Ride). Cites Reddit, YouTube, Snowboarding Forum, Snowboarder Mag, Outside, Whitelines, Facebook. **PAA:** none.
- **Our page:** FAQ "What are good alternatives to Burton snowboards?" exists, but there's no list.
- **Edits:** Add an H2 "Alternatives to Burton" under the picks table: a bulleted list of the brands the page already covers, each with one line from its section (for example "CAPiTA: The Good Ride's #1 all-mountain board, the Matriarch"; "Jones: the Flagship, a top powder pick"; "Lib Tech and GNU (same company)"). Lead it with one sentence: "Burton's biggest rivals for boards are …".

### 8. what is ski-in ski-out lodging (20)
- **Our page:** `/guides/ski-in-ski-out` (GSC 8.6). **Live:** not in top 12.
- **FS:** none. **AIO:** yes. A paragraph definition, then bulleted "key characteristics / benefits / drawbacks", including "true ski-in/ski-out vs slopeside/ski access". Cites East West Hospitality, Vacasa, Ski.com, GoSnowmass, skimag, Summit County Mountain Retreats.
- **PAA:** Is Teton Mountain Lodge ski in ski out? · What does ski in ski out mean on Vrbo? · What ski resorts have lodging? · Where does Kate Middleton go skiing?
- **Our page:** the tldr is 60 words and a good definition. It already has a comparison table and the FAQ "What's the difference between ski-in/ski-out and slopeside?". This page is the closest match of any to the AIO format.
- **Edits:** Add FAQ "What does ski-in/ski-out mean on Vrbo or Airbnb listings?" using the page's existing point that listings use the term loosely, so ask exactly how you reach the nearest lift and how you get back at the end of the day. Rename the tldr's lead-in from "Short answer:" to a direct definition ("Ski-in/ski-out lodging lets you…") to match the AIO's definition sentence.

### 10. what makes snowboard pants a practical choice for resort riding? (15)
- **Our page:** `/guides/snowboard-pants` (GSC 1.7). **Live:** not in top 11. GSC's 1.7 is long-tail variance; the live SERP shows Capelin Crew, snowauthorities and others.
- **FS:** none. **AIO:** async. **PAA:** What kind of pants are best for snowboarding? · What is resort riding snowboard? · Why do snowboarders wear such baggy pants? · Are insulated ski pants worth it?
- **Our page:** the tldr (55 words) is good. FAQ "Should I get insulated snowboard pants?" is close to PAA 4.
- **Edits:**
  - Add FAQ "Why do snowboarders wear baggy pants?" answered from the page: snowboarders sit to strap in, kneel on toeside and fall more while learning, so pants need a roomy fit for wide stances and wide leg openings that fit over boots; relaxed and baggy cuts are popular in the park.
  - Add FAQ "What kind of pants are best for snowboarding?" that reuses the tldr.

### 11. best ski brands (14)
- **Our page:** `/guides/best-ski-brands` (11.9). **Live:** not in top 9. **FS:** none. **AIO:** yes (same brand-list format as #3; same sources). **PAA:** none.
- **Edits:** Covered by #3 (brand-naming tldr, table moved up).

### 12. best snowboard brands (14)
- **Our page:** `/guides/best-snowboard-brands` (8.0). **Live:** not in top 12.
- **FS:** none. **AIO:** yes. It's a brand list ("stand out for innovation, build quality…"). Cites Treeline Review, Whitelines, GearLab, Peter Glenn, Reddit, Faultline395.
- **PAA:** How often should I wax my snowboard? · What's the difference between camber and rocker? · Is it better to rent or buy a snowboard? · Is Burton or Capita better?
- **Edits:**
  - Add FAQ "Is Burton or CAPiTA better?" answered from the page's picks: neither is better overall; CAPiTA has The Good Ride's #1 all-mountain board (Matriarch), while Burton's Cultivator is the most recommended beginner board. Choose by riding style.
  - Add FAQ "What's the difference between camber and rocker?" linking `/guides/best-snowboard`, which has "Is camber or rocker better?". Better still, give the one-line answer from that page.
  - Add FAQ "Is it better to rent or buy a snowboard?" using the `/guides/best-snowboard` line: renting for your first few days is smart; link `/guides/rent-or-buy-ski-gear` (the link that page already uses).
  - Skip the wax question; we have no page facts on waxing intervals.

### 13. all inclusive ski resorts (13)
- **Our page:** `/guides/all-inclusive-ski-resorts` (14.1). **Live:** not in top 10.
- **FS:** none. **AIO:** yes. It opens with the definition "True all-inclusive ski resorts bundle lodging, gourmet dining, open bars, lift passes, and ski or snowboard lessons into a single upfront price", then lists Club Med Tomamu, Club Med Québec-Charlevoix, Club Med Alpe d'Huez, The Ranch at Rock Creek and Ski Portillo. Cites Club Med, Reddit, Ski.com, Matador, POWDER. **PAA:** none.
- **Our page:** the tldr (67 words) already says nearly the same thing and names Club Med Québec Charlevoix. Our body covers The Ranch at Rock Creek. That's a good match, but the tldr is over 60 words.
- **Edits:** Tighten the tldr to about 50 words: "Short answer: true all-inclusive ski resorts, where one price covers lodging, lift tickets, lessons, meals and drinks, are rare in North America. Club Med Québec Charlevoix is the clearest example, and a few Montana luxury ranches, such as The Ranch at Rock Creek, bundle skiing into their stays." Move "Always check what's included…" to the next paragraph. Make sure the resort list is a numbered `<ol>` with the resort name as each item's lead.

### 14. best snowboard for entrepreneurs (13)
- **Our page:** `/guides/best-snowboard-brands` (6.2). **Live:** not in top 10. **FS / PAA / AIO:** none.
- **Edits:** None. The SERP doesn't match the intent (Reddit, a 2013 Forbes piece, an Instagram post). The "for writers / artists / entrepreneurs / homeowners" variants are synthetic long-tail. Don't build pages for them.

### 15. best ski boots for writers (12) and 17. best ski boots for artists (10)
- **Our page:** `/guides/best-ski-boots` (5.8 / 3.0). **Live:** not in top 10. **FS / PAA / AIO:** none.
- **Our page:** the tldr (54 words) is good, and 4 FAQs cover fit, size, flex and pain.
- **Edits:** None for these queries; same reasoning as #14.

### 16. aspen snowmass snow report (11)
- **Our page:** `/resorts/aspen-snowmass` (GSC 53.5). **Live:** not in top 10 (Frias, Mountainwatch, igluski, Snow-Forecast, SnoCountry, Aspen Times).
- **FS:** none. **AIO:** yes. It opens "Check the current conditions on the Aspen Snowmass Snow Report… Projected Opening Date: November 26, 2026. 24-Hour Snowfall: 0 inches." Cites Aspen Snowmass, OnTheSnow, Facebook. **PAA:** none.
- **Our page:** no `.tldr`. The page has a live sentence ("Aspen Snowmass has had no measurable new snow in the last 24 hours. Right now at mid-mountain it's 34°F…") and the FAQ "When does Aspen Snowmass open for the 2026-27 season?" (Nov 26, 2026). It has 12 FAQs.
- **Edits (resort template, all ~180 resort pages):** Add a `.tldr` directly under the H1 made from the existing live fields, about 40 to 50 words: "[Resort] snow report: [X] inches of new snow in the last 24 hours and [Y] forecast over the next 7 days at mid-mountain ([elevation] ft). [Opening date sentence from the FAQ]. For base depth and lifts open, see the official snow report." That's the exact shape the AIO uses (24-hour snowfall plus opening date).

### 18. crystal weather forecast (10)
- **Our page:** `/resorts/crystal-mountain` (GSC 80.9). **Live:** not in top 10. It's a generic weather SERP (Weather Channel, Weather Underground). One PAA question is ours: "Is Crystal Mountain supposed to get snow?"
- **FS / AIO:** none.
- **Edits:** Use the resort tldr template from #16. Add FAQ "Is Crystal Mountain supposed to get snow?" with the same live 7-day forecast sentence the page already renders. The query is ambiguous, so expect little from it.

### 19. moguls (9)
- **Our page:** `/guides/how-to-ski-moguls` (19.8). **Live:** not in top 10.
- **FS:** none. **AIO:** yes. It opens "Moguls are fields of natural or artificial bumps on a ski slope formed when skiers push snow into mounds while making sharp turns", with sections on formation, the Olympic event and tips. No named sources.
- **PAA:** How do they make moguls? · When was freestyle skiing in the Olympics? · Who is considered the best mogul skier of all time? · What size ski should a mogul skier use?
- **Our page:** the tldr is "how to ski moguls" (61 words), but the head term "moguls" wants a definition. That definition already sits in the "What moguls are" section.
- **Edits:**
  - Open the tldr with the definition we already have: "Moguls are the bumps that form when many skiers turn in the same places on a run, pushing snow into mounds with troughs between them. To ski them, keep your upper body facing downhill, let your legs absorb each bump, and turn on the top or side of the mogul." (52 words.)
  - Add FAQ "How do moguls form?" from the same section: snow gets pushed into mounds over a few days of skiing, and some runs are left ungroomed on purpose so moguls build up.
  - Rename FAQ "Are shorter skis better for moguls?" to "What size skis are best for moguls?" (PAA wording) and keep the answer: shorter, narrower, softer skis.

### 20. balaclava vs ski mask (8)
- **Our page:** `/guides/balaclava-vs-ski-mask` (5.9). **Live:** not in top 10 (Reddit r/AskUK, Wikipedia, Turtle Fur).
- **FS:** none. **AIO:** yes. It opens "A balaclava and a ski mask refer to the same general style of headgear, though people often use the terms with slight differences…" Cites Reddit, Wikipedia, TikTok, Turtle Fur, Quora.
- **PAA:** What do Americans call a balaclava? · Why are balaclavas called shiesty? · Are balaclavas illegal? · What culture is balaclava from?
- **Our page:** the tldr (69 words) states exactly the AIO's point but runs long. It has a comparison table, which suits this comparison query.
- **Edits:** Trim the tldr to about 50 words by dropping the neck-gaiter sentence into the table intro. Add FAQ "What do Americans call a balaclava?" with the page's existing line: "ski mask" usually means the same thing, though it can also mean a face-only cover. Skip the other PAAs; they're off-topic for a ski site.

---

## Part 2: Target queries

### T1. denver to breckenridge
- **Our page:** `/getting-there/denver-to-breckenridge`. **Live:** not in top 10 (Epic Mountain Express, Reddit r/Breckenridge, gobreck.com).
- **FS:** none. **AIO:** yes. It opens "Traveling between Breckenridge and Denver covers roughly 80 to 104 miles… via I-70 and CO-9. The trip typically takes 1.5 to 2.5 hours…". Cites Peak 1 Express, Mr. Chauffeur, Google Maps, gobreck.com, Breck Life, Epic Mountain Express, Summit Express, Bustang, Reddit.
- **PAA:** Is it difficult to drive from Denver to Breckenridge? · Is there a shuttle service from Denver Airport to Breckenridge? · How much would an Uber cost from Denver Airport to Breckenridge? · What is the best way to get from Denver to Breckenridge?
- **Our page:** the tldr is 67 words because of the OpenStreetMap and forecast notes. Its 4 FAQs are written generically ("Is there a shuttle or bus…"). The route section is good.
- **Edits:**
  - Replace the tldr with this 54-word version and move the OSM/forecast notes into a small note under it: "Breckenridge is about 104 miles from Denver International Airport, roughly 1 hr 50 min by car via I-70 and CO-9, or 80 miles (1 hr 25 min) from downtown Denver. Without a car, take CDOT's Snowstang ski bus on weekends, Bustang to Frisco plus the free Summit Stage, or a Summit Express airport shuttle."
  - Add FAQ "Is it difficult to drive from Denver to Breckenridge in winter?" using the page facts: I-70 crosses the Continental Divide through the Eisenhower-Johnson Tunnel (up to 11,158 ft); the Traction Law runs Sept 1 to May 31 (3/16-inch tread, M+S or mountain-snowflake tires, or chains); in bad storms CDOT can call the chain law; westbound traffic peaks Friday 2 to 7 pm and eastbound Sunday 3 to 6 pm.
  - Rename "Is there a shuttle or bus from Denver to Breckenridge?" to "Is there a shuttle from Denver Airport to Breckenridge?" and lead with Summit Express (airport shared and private shuttles), then Snowstang ($25 round trip last season, as listed).
  - Add FAQ "What is the best way to get from Denver to Breckenridge?": driving is the most flexible; without a car, Snowstang on weekends or Bustang/Pegasus to Frisco plus the free Summit Stage. CDOT's tip: go midweek or early.
  - Skip the Uber-cost PAA; we have no fare data.

### T2. reno to lake tahoe
- **Our page:** `/getting-there/reno-to-lake-tahoe`. **Live:** not in top 10 (Expedia, Reddit, North Lake Tahoe Express).
- **FS:** none. **AIO:** yes. It opens "The drive from Reno to the North Shore of Lake Tahoe (Incline Village) is about 37 miles and takes around 45 minutes…". Cites Uber, Google Maps, Visit Lake Tahoe, Visit Reno Tahoe, North Lake Tahoe Express, South Tahoe Airporter, Travel Nevada, Reddit.
- **PAA:** How far is Lake Tahoe from Reno, Nevada? · Can you fly from Reno to Lake Tahoe? · Which is better, Reno or Lake Tahoe? · How do I get from Reno Airport to Truckee?
- **Our page:** the tldr is 69 words (padded). It has a per-resort drive-time table, the only table among the route pages, which is good for list/table extraction.
- **Edits:**
  - Replace the tldr with this 55-word version: "From Reno-Tahoe International Airport, Northstar is about 45 minutes, Palisades Tahoe about 50 minutes and Heavenly about 1 hr 10 min by car: I-80 to the North Shore or US-50 to South Lake Tahoe. Without a car, the North Lake Tahoe Express serves the North Shore and Truckee, and the South Tahoe Airporter serves Stateline."
  - Add FAQ "How do I get from Reno Airport to Truckee?": drive I-80 west to Truckee, or take the year-round North Lake Tahoe Express (reserve ahead).
  - Rename "How long is the drive from Reno to Lake Tahoe?" to "How far is Lake Tahoe from Reno?" and answer with the drive-time table rows. If the table has a miles column, add the miles; if not, don't make them up.

### T3. denver to vail
- **Our page:** `/getting-there/denver-to-vail`. **Live:** not in top 10 (Uber, a Facebook group, Peak 1 Express).
- **FS:** none. **AIO:** yes. It opens "Traveling from Denver to Vail covers roughly 96 to 120 miles along I-70 W, with a standard drive time of about 1.5 to 2.5 hours…". Cites Peak 1 Express, Mr. Chauffeur, Google Maps, Four Seasons, Rome2Rio, Blacklane, Reddit, Summit Express, Epic Mountain Express, Uber.
- **PAA:** How much does a Denver to Vail shuttle cost? · Which is nicer, Aspen or Vail? · Is it better to fly into Vail or Denver? · How long is a flight from Vail to Denver?
- **Our page:** the tldr is 66 words (padded). It already has FAQ "Can I fly closer to Vail?" and an EGE section.
- **Edits:**
  - Replace the tldr with this 55-word version: "Vail is about 121 miles from Denver International Airport, roughly 2 hours by car on I-70 over Vail Pass, or 97 miles (1 hr 35 min) from downtown Denver. Without a car, take CDOT's Bustang or year-round Pegasus van from Union Station, or a Summit Express shuttle. Eagle County Regional (EGE) is the closest airport."
  - Rename "Can I fly closer to Vail?" to "Is it better to fly into Vail or Denver?" and answer: EGE in Gypsum is the closest airport (last winter 4 airlines and 16 nonstop destinations); DEN is about 2 hours by car.
  - Add FAQ "Which is nicer, Aspen or Vail?" with a short answer and a link to `/compare/aspen-vs-vail` (the page exists).
  - Skip the shuttle-cost PAA; no fares are listed.

### T4. salt lake city to park city
- **Our page:** `/getting-there/salt-lake-city-to-park-city`. **Live:** not in top 10 (Lyft, Hall Utah, a Facebook group).
- **FS:** none. **AIO:** yes. It opens "…covers about 30 to 35 miles and takes roughly 40 to 50 minutes by car…". Cites Prime Time Shuttle, Uber, Rome2Rio, Turo, High Valley Transit, Salt Lake Express, Megabus, Reddit, Canyon Transportation.
- **PAA:** What is the distance from Salt Lake City to Park City? · Is there a shuttle from Park City to the airport? · Can I get around Salt Lake City without a car? · What is the drive like from SLC to Park City?
- **Edits:**
  - Replace the tldr with this 50-word version: "Park City is about 38 miles from Salt Lake City International Airport, roughly 40 minutes by car on I-80 through Parleys Canyon, or 31 miles (35 minutes) from downtown. Without a car, take High Valley Transit Route 107 to Kimball Junction, or a Canyon Transportation or Salt Lake Express shuttle."
  - Add FAQ "What is the drive like from Salt Lake City to Park City?": I-80 east up Parleys Canyon over Parleys Summit to Kimball Junction, then SR-224. UDOT applies a traction law in Parleys Canyon during storms, and crashes on icy mornings can back up eastbound I-80 for miles.
  - Rename "Is there a shuttle or bus…" to "Is there a shuttle between Park City and the airport?" (Canyon Transportation, Salt Lake Express).
  - Rename "How long is the drive…" to "What is the distance from Salt Lake City to Park City?"

### T5. hot springs in colorado
- **Our page:** `/hot-springs-in-colorado`. **Live:** not in top 10 (a local map pack, then The World on my Necklace, colorado.com, Iron Mountain).
- **FS:** none. **AIO:** none.
- **PAA:** Does Colorado have natural hot springs? · Is Glenwood Hot Springs worth it? · What are the best hot spring resorts in Colorado? · Where are all the hot springs in Colorado?
- **Our page:** the tldr is 167 words with 3 bullet points: far too long. The comparison table (town, kids, reservations, nearest ski resort) is strong.
- **Edits:**
  - Cut the tldr to 56 words: "Colorado has 19 hot springs on our list, and 16 are close to a ski resort. Glenwood Hot Springs Resort and Iron Mountain Hot Springs in Glenwood Springs are the big family pools; Strawberry Park near Steamboat is a natural soak that requires reservations. The Historic Hot Springs Loop links 23 facilities over about 800 miles." Move the three bullets (Loop, Routt County 4WD rule, Pagosa flood) into a "Good to know" box below.
  - Add FAQ "Does Colorado have natural hot springs?": yes, for example Strawberry Park Hot Springs (stone-walled natural pools outside Steamboat, open 365 days, reservations required) and Yampah's natural underground steam caves.
  - Add FAQ "Is Glenwood Hot Springs worth it?" with page facts only: a big family pool, adult day pass from $38 as listed 2026-11-08, reservations not required, open in winter, near Sunlight Mountain.
  - Add FAQ "Where are all the hot springs in Colorado?": the Colorado Historic Hot Springs Loop (about 800 miles, 23 facilities in 8 destinations: Steamboat Springs, Glenwood Springs, Carbondale, Ouray, Durango, Pagosa Springs, Saguache County, Chaffee County).

### T6. best winter vacations in the us
- **Our page:** `/best-winter-vacations-in-the-us`. **Live:** not in top 10 (Global Grasshopper, Em's On The Road, Reddit).
- **FS:** none. **AIO:** yes. It splits snowy picks (Aspen, Park City, Tahoe, Yellowstone, Fairbanks) from warm picks (Key West, Palm Springs and others). Cites Quora, Reader's Digest, Global Grasshopper, National Geographic, Amex, TikTok.
- **PAA:** Where is the cheapest place to vacation in the winter? · Which state is best to visit in winter? · Where to go for 3 days in the USA? · What are some good places to go on winter vacation in America?
- **Our page:** the tldr is 87 words (padded with "For a snowy winter trip…" and the live-snow timestamp). The page has a numbered list of 15 trips with states. FAQ titles have a typo: "Why visit Yellowstone National Park in winter in winter?"
- **Edits:**
  - Trim the tldr to its first sentence (about 55 words). Move the timestamp out of `.tldr`.
  - Fix the FAQ typo, which reads "…in winter in winter?".
  - Add FAQ "Which state is best to visit in winter?" answered from the list: Colorado appears three times (Breckenridge, Steamboat Springs, Telluride), and Wyoming, California and Washington twice each. Name the trips. Don't claim a single "best" beyond what the list says.
  - Make sure the 15 picks render as a real `<ol>` with "Place, State" as each item's lead (the AIO pulls lists).
  - Expect limited gains: the AIO mixes in warm destinations we don't cover.

### T7. best ski resorts for beginners
- **Our page:** `/best-ski-resorts-for-beginners`. **Live:** not in top 10 (campfiresandconcierges, skiresort.com, iloveny, Snow.com, PeakRankings).
- **FS:** none. **AIO:** present, but it loaded async (no sources returned). **PAA:** none.
- **Our page:** the tldr is 65 words and names 5 resorts with their beginner-terrain share, a good list shape. It has a table and 10 state FAQs.
- **Edits:** Move the caveat sentence ("Beginner terrain shares are as published…") out of the `.tldr` into the table caption. That brings it to about 45 words. No new FAQs needed.

### T8. things to do in breckenridge in winter
- **Our page:** `/things-to-do-in-breckenridge-in-winter`. **Live:** not in top 10 (gobreck.com, Grand Lodge on Peak 7, Tripadvisor).
- **FS:** none. **AIO:** yes. It opens "Breckenridge, Colorado offers a wide range of alpine adventures, rich history, and family-friendly activities during the winter season." Cites Best of Breckenridge, Breckenridge Ski Resort, gobreck.com, Tripadvisor, VisitBreck. **PAA:** none.
- **Our page:** the tldr is 91 words. The first list appears about 24 headings down, so activities are headings rather than a scannable list.
- **Edits:**
  - Cut the tldr to its first and third sentences (about 50 words): "Beyond the slopes, Breckenridge in winter means snowmobiling (Good Times Adventures), dog sledding (Good Times Adventures), sleigh rides (Breckenridge Stables) and ice skating (Stephen C. West Ice Arena). The free BreckConnect Gondola runs from town to Peak 7 and Peak 8, and two Nordic centers groom trails near town."
  - Add a bulleted "At a glance" list right under the tldr with one line per activity heading already on the page, matching the AIO's list format.

### T9. best places to ski in december
- **Our page:** `/best-places-to-ski-in-december`. **Live:** not in top 10 (skimag, Reddit, Instagram).
- **FS:** none. **AIO:** yes. Its North America picks are Utah (Alta, Snowbird, Deer Valley), Colorado (Vail, Aspen, Keystone), Killington, Whistler and Alyeska. Cites chaletskiholidays, Reddit, OnTheSnow, ZRankings, skimag, YouTube.
- **PAA:** Where are the best places to ski in Europe in December? · Where does Kate Middleton go skiing? · Where are the best ski conditions in the US right now? · Where to ski in December in the USA?
- **Our page:** the tldr is 87 words; it carries a definition of "snow days" that belongs in the table caption. The table and 7 FAQs (Colorado, Utah, California, Canada, East) cover the AIO's regional structure well.
- **Edits:**
  - Replace the tldr with this 52-word version: "The best places to ski in December, by how often it snows, are White Pass, Mt. Baker and Stevens Pass in Washington, each with snow on about 15 to 16 of December's 31 days. That's from 10 seasons of daily weather history, counting days with an inch or more of new snow."
  - Add FAQ "Where are the best ski conditions in the US right now?" that points to the live `/where-is-it-snowing` ranking (no new numbers).
  - Rename "Where is the best place to ski in December?" to "Where should I ski in December in the USA?" (PAA wording).
  - Cite the Powder Day Odds study (CC BY dataset) on-page as the source. ZRankings and OnTheSnow get cited for this exact data type.

### T10. best snowboard
- **Our page:** `/guides/best-snowboard-brands` (titled "Best Snowboards 2026-27"). **Live:** not in top 10 (Snow Magazine, GearJunkie, Snowboarding Profiles, The Good Ride, Reddit, 2 shopping carousels).
- **FS:** none. **AIO:** present, but it loaded async (no sources). **PAA:** none.
- **Edits:** Same as #1 (49-word tldr naming the Highpath, Matriarch and Cultivator with prices). Consider giving `/guides/best-snowboard` (the "how to choose" page) a distinct title so the two URLs don't split "best snowboard" impressions. GSC already shows both URLs ranking for "what is the best snowboard".

---

## Template-level changes (biggest reach)

1. **`.tldr` contents, sitewide:** keep only the answer inside `.tldr` (40 to 60 words). Move method notes ("Drive times are estimates from OpenStreetMap routing…", "Snow forecast updated…", "Live snow… updated…", definitions of metrics, terrain-share caveats) into a separate element just below it. Affected: all `getting-there/*`, `best-places-to-ski-in-*`, `best-winter-vacations-*`, `best-ski-resorts-for-beginners`, `things-to-do-*`, `hot-springs-*`.
2. **Resort pages have no `.tldr`:** add one built from the existing live fields (24h snow, 7-day forecast, opening-date sentence). That's the exact shape of the "[resort] snow report" AI Overview.
3. **Route-page FAQ template:** reword the generic FAQs to PAA phrasing and add "Is it difficult to drive from X to Y in winter?" and "What is the best way to get from X to Y?", filled from the existing route and winter-driving blocks.
4. **"Short answer:" prefix:** fine for readers, but for definition queries (ski-in/ski-out, après-ski, moguls) start the sentence with the term itself ("Après-ski is…"). AI Overviews lift definitions that begin with the term.
