# Fact rechecks

Time-sensitive facts that were "not posted yet" or dated when researched (2026-11-08). A one-time cloud routine runs this on 2026-12-01; rerun each season (early December and early October).

## How to recheck
For each item: fetch the official source, update the YAML only if the source now says something different or newly posts the info, and keep the "as listed on <date>" wording with the new date. Never guess. Normal fetching only: if a site blocks automated access, skip it and note it. Run `bin/rails test` before committing.

## db/routes.yml (Getting There pages)
- Snowstang (CDOT) 2026-27 dates and fare: denver-to-breckenridge, denver-to-copper-mountain options.
- Winter Park Express (Amtrak ski train) 2026-27 dates: denver-to-winter-park.
- TART winter timetable (Tahoe), OvR Killington trips, Park City Transit winter schedule: matching routes.
- Winter flight lists for TEX, MTJ, GUC, HDN, EGE, MMH: the fly_closer notes that cite last winter.
- BC Highway 99 winter tire end date (March 31 vs April 30): vancouver-to-whistler.
- El Dorado Transit Sacramento to Tahoe times (schedule PDF may be from 2024).

## db/winter_towns.yml (Things to do in winter)
- 2027 event dates: Wintersköl (Aspen), SnowFest (Tahoe), Stowe Winter Carnival, Steamboat Winter Carnival schedule, Jackson events (Pedigree Stage Stop, Hill Climb), Ullr Fest and the Snow Sculpture Championships (Breckenridge).
- National Elk Refuge sleigh ride 2026-27 dates and price (entry still shows 2025-26).
- Operators whose pages showed last season as ended: Snowmobile Vermont, von Trapp Outdoor Center, Steamboat nordic centers, Whistler tube park.
- Prices marked null because the page showed none: fill in only if now listed.

## db/travel_lists.yml
- Leavenworth Village of Lights dates; Paradise (Mount Rainier) sledding status; Lake Placid bobsled experience status.
- Colorado hot springs: Healing Waters (Pagosa) reopening after the October 2025 flood; prices with two tables (Glenwood, Avalanche Ranch); reservation rules marked null.
- Sun Valley Dollar Mountain 2026-27 reopening.

## db/pass_guide.yml
- Epic and Epic Local prices after the Nov 15, 2026 increase (epicpass.com; news fallback EpicOrIkon). Indy Pass back on sale? Mountain Collective deadline. Ikon young adult and child prices for Base.

## db/resort_facts.yml
- Epic and Ikon pass prices (Epic prices rose after Nov 15, 2026).
- Opening dates that slipped (check resorts with opening_status "scheduled" in the past).
