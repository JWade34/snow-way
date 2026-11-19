# NOAA weather-station review (2026-11-19)

**Why:** the ERA5 model (Open-Meteo) undercounts mountain snow (Jim Steenburgh, 11/9). SNOTEL fixed the West on 11/10, but the East, Midwest, Canada and ~10 big western names were still shown with model numbers. Justin, 11/19: no bad data anywhere on the site. Model snow-day numbers are now shown nowhere.

**Data:** NOAA ACIS (data.rcc-acis.org, no key): daily snowfall from NWS co-op, CoCoRaHS and Environment Canada observers. A snow day = 1.0"+ measured new snowfall. Values flagged A (multi-day total), S, M are skipped.

**Match rules** (auto-searched, then checked): station within 5 miles of the resort point; elevation no more than 800 ft below the base and no higher than summit + 500 ft; 8+ of the 10 winters (2015-16 to 2024-25) with 80%+ of Nov-Apr days reported. Among candidates, highest elevation first. quality good = within 2 miles and within 500 ft of the base.

**Overrides:** Wildcat uses Pinkham Notch (co-op since 1930, 0.9 mi) instead of the Mount Washington summit (6,272 ft, above any lift).

**Measured vs model (season snow days):** Jay Peak 47 vs ~29, Wildcat 41 vs ~30, Smuggs/Stowe 42 vs ~25/26. Measured runs ~1.5x the model, like the West (1.4x).

**Rejected (no number shown):** Aspen (Aspen 1SW, 6.2 mi), Northstar (Incline Village, 9.8 mi), Jackson Hole and Snow King (Wilson, 9.0/6.9 mi), Killington (Chittenden, 10 mi), Sugarbush (South Lincoln, 5.6 mi), Mad River Glen (South Lincoln, 9.4 mi), Keystone (Breckenridge, 9.4 mi), Sugarloaf (Kingfield, 8.4 mi, 800 ft below base), Bretton Woods (Mt Washington summit), Gore (North Creek, 5.5 mi), Powder Mountain and Snowbasin (Eden, valley), Mountain High (Pinon Hills, desert), Sunlight (Carbondale), Wachusett (Ashburnham, 8.2 mi), Crystal MI, Nubs Nob, The Highlands, Spirit Mountain, Attitash, Belleayre, Greek Peak, Holiday Valley, Camelback, Ober (Mt LeConte summit), Magic, Canaan Valley, Wilmot, Kicking Horse (Golden airport, 1,300 ft below base), Whitewater, Nakiska, Cypress, Mount Seymour, Blue Mountain ON, Mount St. Louis. Plus every resort with no station within 10 miles reporting 8+ winters (Mammoth, Sun Valley, Whitefish, Mt. Bachelor, Mt. Baker, Whiteface, Stratton, Mount Snow, Okemo, Bolton, Cannon, Loon, Waterville, Sunday River, Hunter, Windham, most Canadian resorts).

**Limits:** most stations are at the base or in the valley, so they read lower than the slopes. CoCoRaHS volunteers skip some days (Westfield/Jay: 85% coverage). Stowe borrows Jeffersonville (north side of Mansfield); the Mount Mansfield co-op (3,950 ft) ends 12/2017 in ACIS.

**Still modeled, labeled:** `monthly_snow_share` (share of season snowfall by month: best-time chart and FAQs, regions, comparisons, powder calendar). Checked 11/19 against measured snow-day odds for 86 resorts: model's #1 month is in the measured top 3 for 75 (87%); top-3 overlap 2.38 of 3. Labeled as a model pattern, not totals. Candidate follow-up: drive "best months" from measured odds where they exist.

**Next:** Ken Mahan (Boston Globe, call 11/20) may know better New England stations (Mansfield stake, MWO, co-op). Rerun: edit db/weather_stations.yml, then `bin/rails resorts:weather_station_odds`.
