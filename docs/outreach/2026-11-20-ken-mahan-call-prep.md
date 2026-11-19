# Call prep: Ken Mahan, Boston Globe (Fri 11/20, 1:00 PM ET / 12:00 CT, Google Meet)

Ken is the Globe's lead meteorologist and writes the weekly New England ski forecast column. He replied 11/12 ("I'd love to learn a bit more") and confirmed 1:00 PM ET on 11/19.

## What "the study" is
The Powder Day Odds page (snowway.app/powder-day-odds), the link you sent him. It answers one question: how often does each resort actually get new snow? It counts days with an inch or more of new snow, November to April, over 10 winters (2015 to 2025). It counts how often it snows, not how many inches.

## How it got here (tell it in this order)
1. **Version 1, what you emailed him:** a weather model (ERA5 reanalysis, via Open-Meteo) for every resort. That's where Wildcat 30, Jay 29, Stowe 26 came from.
2. **The correction:** Jim Steenburgh (University of Utah, mountain weather) replied to the same pitch: that model undercounts mountain snow. Published research agrees.
3. **The West, live 11/10:** switched to USDA SNOTEL snow stations, automated sensors on the mountains, hand-matched to each resort. Real counts came out about 1.4x the model.
4. **The East, live 11/19:** SNOTEL doesn't exist in the East, so we now use NOAA weather stations, where co-op and CoCoRaHS observers measure new snow every morning. Real counts came out about 1.5x the model. Resorts without a good station get no number at all. The old model numbers are gone from the site.

Opening line:
> "Since I emailed you, a Utah meteorologist told me the reanalysis model undercounts mountain snow. We rebuilt the West on SNOTEL, and yesterday we rebuilt the East on NOAA co-op and CoCoRaHS stations. The New England numbers I sent you were low. Jay Peak is really about 47 snow days, not 29. I'd love your read on which New England stations you'd trust."

## New England numbers now on the site
Days with 1"+ of new snow, Nov to Apr, 2015-16 to 2024-25.

| Resort | Station | Distance / elev | Snow days / season | Dec | Jan | Feb | Model said |
|---|---|---|---|---|---|---|---|
| Jay Peak | Westfield (CoCoRaHS volunteer, 85% of days reported) | 3.9 mi, 1,069 ft | **47** | 32% | 38% | 33% | ~29 |
| Smugglers' Notch | Jeffersonville co-op | 0.3 mi, 1,163 ft | **42** | 26% | 34% | 34% | ~25 |
| Stowe | Jeffersonville (north side of Mansfield) | 3.7 mi, 1,163 ft | **42** | 26% | 34% | 34% | ~26 |
| Wildcat | Pinkham Notch co-op (records since 1930) | 0.9 mi, 2,025 ft | **41** | 26% | 32% | 31% | ~30 |
| Cranmore | North Conway | 1.0 mi, 522 ft | **20** | 12% | 18% | 20% | ~17 |

For reference: Mount Washington summit (6,272 ft) gets ~70 snow days, but it's above any lift, so it isn't used.

**No number shown** (no station close enough to trust): Killington, Sugarbush, Mad River Glen, Sugarloaf, Sunday River, Bretton Woods, Cannon, Loon, Waterville, Attitash, Stratton, Mount Snow, Okemo, Bolton, Magic, Whiteface, Gore, Hunter, Windham, Wachusett. **This is the best question for Ken:** does he know stations for these?

## How you can be confident
- Every number is free government data anyone can check: USDA for the West, NOAA for the East.
- The rules are simple and published on the page: 1 inch or more = a snow day; 10 winters; station within 5 miles, no more than 800 ft below the base, at least 8 winters with 80%+ of days reported. No good station = no number.
- You changed the method when an expert flagged a problem, and you're telling Ken first. Meteorologists respect that.

## Be honest about the limits (if he asks)
- East stations sit at the base or in the valley, so the slopes likely see snow more often than these show.
- Volunteers skip some days; we only use winters with 80%+ of days reported.
- Stowe borrows the Jeffersonville station. NOAA's Mount Mansfield co-op record (3,950 ft, since 1954) ends in Dec 2017.
- The East and West lists are kept separate: different instruments at different heights.

## What to have open (tabs, in order)
1. snowway.app/powder-day-odds: scroll to the New England finding at the top, then "The East, Canada and more: weather stations" table, then "How we measured"
2. snowway.app/resorts/wildcat-mountain/best-time-to-ski (Pinkham Notch month-by-month)
3. snowway.app/best-places-to-ski-in-december (East list)
4. This doc

## Questions to ask Ken (let him talk)
1. What made you want to talk? What would be useful for the column this winter?
2. Which New England stations would you trust? Co-op, CoCoRaHS, Mount Washington Observatory, the Mansfield stake? Any for Killington, Sugarloaf, Sunday River, the Franconia resorts?
3. Is "an inch or more" the right cutoff for skiers, or would 3"+ or 6"+ days be more useful?
4. How are you thinking about El Niño this winter for northern New England?
5. Would a by-month chart (best odds for Christmas week or Presidents' week) be useful for the Globe? In what format?

## What you can offer
- Run numbers for any mountain or storm he's writing about, fast.
- Fill in the missing New England resorts with stations he recommends, and credit his input on the method.
- Free use under CC BY 4.0 with a link to snowway.app/powder-day-odds.
- Your angle: ran a snowboard shop for years, built Snow Way as a free tool.

Ask for nothing more. The best outcome is Snow Way cited in his column and a standing relationship for the season. If he offers to cite it, ask how he'd like it credited.

## Don't
- Don't defend the old model numbers. Agree they ran low; that's why you rebuilt.
- Don't claim inch totals. It's how often it snows, not how much.
- Don't pitch anything paid or mention jm/SuperDupr services.

## After the call (same day)
- Thank-you email with whatever you promised (numbers, a chart, the CSV).
- Log it in `2026-11-backlink-campaign.md`.
- Add any stations he names to `db/weather_stations.yml`, run `bin/rails resorts:weather_station_odds`, push. Method notes: `docs/seo/noaa-station-review.md`.
