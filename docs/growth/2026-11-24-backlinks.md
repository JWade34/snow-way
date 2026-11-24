# Snow Way backlinks: every way to get other sites linking (2026-11-24)

**Why this matters:** Bing lists zero sites linking to Snow Way. It has indexed 72 of 1,316 pages and reads about 15 a day. Google has 594 indexed and is slow on new pages; the holiday guide sat unseen for 3 weeks. Links from other sites are what fix crawl speed, rankings, and how often ChatGPT, Gemini and Google's AI answers name Snow Way.

**Rule:** never buy links, never use link networks or fake accounts. Google penalizes paid links, and a young site doesn't recover easily. Everything below is earned or owned.

Ranked by value for effort. Owner: **J** = Justin, **C** = Claude drafts and Justin sends or posts.

## 1. Already lined up
| Source | What to do | Owner | When |
|---|---|---|---|
| Boston Globe (Ken Mahan's weekly Thursday ski forecast, about 1M subscribers) | Ken said on 11/20 he'll link Snow Way every week, editors cleared it. Justin sent him /new-england and the credit line on 11/21. Next touch: around Dec 10 with a real reason (first big New England storm, or asking if the teaser runs), and ask that the online piece links the page. | J (C drafts) | ~Dec 10 |

## 2. Your own sites (free, today)
| Source | Status |
|---|---|
| justinmckelvey.com /work card, /projects/snowway | Already linked. 11/24: project page now links 8 Snow Way pages directly (Christmas, gift guides, New England, December...), /about names Snow Way |
| superdupr.com/work/snow-way | Done 11/24 (sd 3e908ab): links 8 Snow Way pages. Justin OKd it during the proof-run freeze |
| justinmckelvey.com blog post: building Snow Way with Claude Code (173 of 186 commits) | Draft below needs Justin's own story first |
| LinkedIn profile Featured section + one post | J |

## 3. The free widget (built, needs outreach)
The embed snippet at snowway.app/widget already includes a plain "Ski resort snow forecasts by Snow Way" link under the iframe, so every embed is a real link.
Targets, best first:
1. **Ski and snowboard shops** (Justin ran shops for 12 years: a real reason to write). Shop sites love a live "where's it snowing" box.
2. **Ski clubs and college ski and snowboard teams** (club sites, often .edu).
3. **Slopeside lodging, rental managers and ski-town businesses** (powder forecast on their site keeps guests planning).
4. **Ski bloggers and trip-planning sites.**
5. **Local news weather pages** in ski states (ties to #4 below).
Pace: 10 to 15 personal emails a week, from the Snow Way address, Justin sends. Prospect contacts stay in ~/Desktop/projects/outbound-data/snowway/, never in git.

## 4. Journalists and data requests
- **Pitch storm data before big storms:** "where's it snowing this weekend" with Snow Way's 7-day numbers, to ski writers and TV meteorologists in Denver, Salt Lake, Tahoe/Reno, Seattle, Boston, Burlington. Same play that got Ken.
- **Source request sites:** Qwoted, Featured.com, Source of Sources. Answer ski, travel and weather requests as Justin (built Snow Way, ran snowboard shops in Colorado).
- **Data stories Snow Way can publish once and pitch:** snowiest resorts this season so far, which pass's resorts got more snow (Ikon vs Epic, already live), best December resorts by measured snow (live). Each is a page a reporter can cite.

## 5. Directories and launch sites (lasting links)
| Site | Notes | Owner |
|---|---|---|
| Product Hunt | Launch in early December, before Christmas trip planning peaks. Listing copy below | J posts, C drafts |
| AlternativeTo | List as an alternative to OpenSnow, OnTheSnow, Snow-Forecast | J (account) |
| BetaList, Indie Hackers, SaaSHub, Launching Next | One listing each | J (accounts) |
| Apple-style "best ski apps" roundups | Email the authors of the top 10 Google results for "best ski apps 2026" asking to be considered | C drafts |

## 6. Communities (helps AI answers more than Google)
Reddit (r/skiing, r/snowboarding, r/Tahoe, r/COsnow, r/icecoast, r/skiing_trips), TGR forums, Newschoolers, SkiTalk. These links are mostly nofollow, but ChatGPT and Perplexity cite Reddit constantly. Rules: Justin's own account, answer the actual question with real numbers, link only when it is the answer. No fake accounts.

## 7. Partners already in the money flow
- **Stay22 and affiliate partners:** ask about partner spotlights or case studies.
- **Resorts and tourism boards:** offer the resort's own embed (snowway.app/embed/resorts/<slug>) for their snow report page. Long shot, high value.
- **Snow data sources:** Open-Meteo lists apps that use it; ask to be listed.

## Track it
Bing Webmaster > Backlinks (0 on 11/24) and the Ahrefs/DataForSEO backlink count, monthly. Reads 12/22 with the rest of the 11/24 baseline.

---

## Drafts (voice-checked: short, plain, one sincere question, no invented claims)

### A. Widget email to a ski shop
Subject: Free snow forecast box for your site

Hi [name],

I ran snowboard and bike shops in Colorado for 12 years before I got into software. I built Snow Way, a free site that ranks every resort by the next 7 days of snow and updates every 6 hours. There's a free box you can drop on your site with one line of code, and it'd show [shop]'s customers which mountains are getting hit this week: snowway.app/widget

No cost, no account. Would that be useful on your site, or is there a resort you'd want it to focus on?

Justin

### B. Product Hunt listing
- **Name:** Snow Way
- **Tagline (60 chars):** Find the ski resort getting the most snow this week
- **Description:** Snow Way ranks 179 North American ski resorts (and 35 abroad) by the next 7 days of snow, updated every 6 hours. It also shows when each resort usually gets the most snow, from 10 seasons of measured station data, plus opening dates, pass access and where to stay. Free, no account.
- **Maker comment (Justin, needs his OK):** I ran snowboard shops in Colorado for 12 years before I got into software. [Justin: one line on why you built it.] Snow Way pulls forecasts every 6 hours and shows real measured snow history, never a modeled guess. What would make it more useful for your trips?

### C. AlternativeTo listing
Snow Way: free ski snow forecasts. Ranks every North American resort by 7-day snowfall, with measured December-to-April snow history, powder alerts by email and a weekly snow report. Alternative to OpenSnow, OnTheSnow and Snow-Forecast.

### D. Note to Ken (for when the series starts)
Hi Ken, here are the links for the series: snowway.app/new-england (Vermont, New Hampshire and Maine ranked by the next 7 days, plus the last 24 hours, 48 hours and 7 days), and snowway.app for the credit line. If the online piece can link the page directly, that helps readers find the latest numbers. Anything you want added before the first one runs?

Justin

### E. jm.com post (needs Justin's input before it's written)
Working title: "I built a ski forecast site with Claude Code. Here's what it took."
Verified facts to use: first commit Jan 6, 2026; 173 of 186 commits written with Claude Code; Rails 8 + SQLite; Open-Meteo forecasts every 6 hours; SNOTEL and NOAA measured history; 1,300 pages; Google impressions went from about 150 a week in October to 41,000 a week by mid-November.
Questions for Justin: why you started it, the hardest part, what you'd tell a business owner who wants to build their own tool, and whether you'll share the affiliate side (it's tiny so far).
