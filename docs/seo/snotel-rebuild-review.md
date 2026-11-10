# SNOTEL rebuild: review before anything goes live

Branch `snotel-rebuild` (local only). Nothing on snowway.app has changed yet.

## Why
Jim Steenburgh (University of Utah) replied to the powder-odds pitch on 2026-11-09: ERA5 is not a good tool for estimating snowfall in mountainous terrain. Published research agrees: ERA5 underestimates mountain snow, and more so at higher elevations.

## Method
- **Data:** USDA NRCS SNOTEL automated snow stations. Free public data, no key needed.
- **Station match:** hand-reviewed in `db/snow_stations.yml`. The station must be on the same mountain or in the same drainage, near mid-mountain, with 8+ of the last 10 winters of data.
- **Snow day:** the snow pillow water reading rose 0.1 inch or more (about an inch of snow) on a day averaging 34°F or colder.
- **Seasons:** 2015-16 to 2024-25, November to April.
- **Rules tested and rejected:**
  - Water rising alone counted rain on the snowpack (Crystal came out at 100 days).
  - Water plus a 1-inch depth rise undercounted dry Colorado snow, which settles fast.
  - The temperature rule sits between the two. The top 15 is nearly the same set under all three rules.
- **Validation:**
  - Snow water on snow days × 12 gives estimated snowfall. Against resort-reported averages, the median is 87%.
  - Wet Pacific Northwest snow reads high and dry Rockies snow reads low, as expected from different snow-to-water ratios.
  - The site will publish snow-day frequency only, not inch totals, and the method notes will say so.

## New top 15 (58 resorts with an approved station)

| # | Resort | Snow days | Was (model) | Station |
|---|---|---|---|---|
| 1 | White Pass, Washington | 101 | #2 (75 days) | Pigtail Peak, 1.1 mi (good) |
| 2 | Schweitzer, Idaho | 91 | #17 (47 days) | Schweitzer Basin, 0.9 mi (good) |
| 3 | Mt. Hood Meadows, Oregon | 90 | #5 (67 days) | Mt Hood Test Site, 2.6 mi (good) |
| 4 | Timberline, Oregon | 90 | #6 (66 days) | Mt Hood Test Site, 0.7 mi (good) |
| 5 | Grand Targhee, Wyoming | 87 | #7 (60 days) | Grand Targhee, 1.6 mi (good) |
| 6 | Summit at Snoqualmie, Washington | 84 | #3 (70 days) | Olallie Meadows, 3.7 mi (ok) |
| 7 | Crystal Mountain, Washington | 83 | #4 (68 days) | Morse Lake, 1.9 mi (good) |
| 8 | Montana Snowbowl, Montana | 82 | #41 (33 days) | Stuart Mountain, 3.7 mi (ok) |
| 9 | Stevens Pass, Washington | 76 | #1 (76 days) | Stevens Pass, 0.2 mi (good) |
| 10 | Discovery, Montana | 74 | #40 (33 days) | Warm Springs, 4.0 mi (ok) |
| 11 | Big Sky, Montana | 70 | #29 (40 days) | Lone Mountain, 1.5 mi (good) |
| 12 | Lookout Pass, Idaho | 69 | #8 (57 days) | Lookout, 0.4 mi (good) |
| 13 | Alta, Utah | 66 | #19 (46 days) | Snowbird, 1.7 mi (good) |
| 14 | Snowbird, Utah | 66 | #18 (47 days) | Snowbird, 1.0 mi (good) |
| 15 | Brundage, Idaho | 63 | #10 (54 days) | Brundage Reservoir, 2.9 mi (good) |

## Biggest movers

| Resort | Model rank | Measured rank | Days (model to measured) |
|---|---|---|---|
| Bridger Bowl | #52 | #17 | 23 to 62 |
| Montana Snowbowl | #41 | #8 | 33 to 82 |
| Discovery | #40 | #10 | 33 to 74 |
| Boreal | #11 | #36 | 52 to 49 |
| Sugar Bowl | #13 | #37 | 50 to 49 |
| Kirkwood | #21 | #44 | 46 to 47 |
| Heavenly | #24 | #47 | 43 to 44 |
| Bogus Basin | #47 | #25 | 27 to 56 |
| Crested Butte | #25 | #45 | 42 to 46 |
| Alyeska | #12 | #31 | 50 to 52 |
| Palisades Tahoe | #22 | #40 | 44 to 48 |
| Big Sky | #29 | #11 | 40 to 70 |

The median resort moves 7 places out of 58.

## Weak matches: your call (held back for now)

| Resort | Measured days | Model days | Station | Why it is weak |
|---|---|---|---|---|
| Breckenridge | 49 | 31 | Hoosier Pass, 8.4 mi | South over the ridge. Copper Mountain (7 mi) is a different mountain. |
| Jackson Hole | 69 | 55 | Phillips Bench, 6.5 mi | Teton Pass, south of the resort. No SNOTEL on the mountain. |
| Keystone | 55 | 33 | Grizzly Peak, 5.4 mi | At A-Basin, higher and snowier than Keystone. |
| Mt. Baker | 77 | 78 | Wells Creek, 5.7 mi | Valley below the ski area. Likely undercounts the famously snowy upper mountain. |
| Northstar | 33 | 36 | Truckee #2, 3.8 mi | Near the base, about 1,000 ft below mid-mountain. |
| Telluride | 47 | 38 | Idarado, 7.4 mi | Over the ridge. The Alta Lakes station next to the resort only started in 2025. |
| Winter Park | 64 | 37 | Berthoud Summit, 5.8 mi | Berthoud Pass, higher than the ski area. |

## No suitable station (labeled as model estimates, kept out of rankings)
Aspen Snowmass, Mt. Bachelor, Powder Mountain (station only since 2021), Snowbasin, Sun Valley, Tamarack, Snow King, Silver Mountain, Ski Cooper, Mt. Ashland, Terry Peak, and every resort in Canada, the Midwest and the East (about 113 resorts in all).

## All approved stations

| Resort | Station | Miles | Quality | Note |
|---|---|---|---|---|
| Alta | Snowbird (9170 ft) | 1.7 | good | Same canyon (Little Cottonwood). The Atwater station at Alta only started in 2022. |
| Alyeska | Mt. Alyeska (1500 ft) | 0.8 | good |  |
| Angel Fire | Palo (9330 ft) | 3.6 | ok |  |
| Arapahoe Basin | Grizzly Peak (11110 ft) | 0.3 | good |  |
| Arizona Snowbowl | Snowslide Canyon (9720 ft) | 3.5 | ok | Same mountain (San Francisco Peaks). |
| Beaver Creek | Mccoy Park (9500 ft) | 1.5 | good | On the mountain. The Beaver Ck Village station sits at the base and reads low. |
| Beaver Mountain | Klondike Narrows (7280 ft) | 3.0 | ok | Same canyon (Logan Canyon). |
| Big Sky | Lone Mountain (8820 ft) | 1.5 | good |  |
| Bogus Basin | Bogus Basin (6370 ft) | 0.3 | good |  |
| Boreal | Css Lab (6890 ft) | 1.3 | good | UC Berkeley Central Sierra Snow Lab at Donner Summit. |
| Brian Head | Brian Head (10040 ft) | 1.6 | good |  |
| Bridger Bowl | Brackett Creek (7370 ft) | 5.5 | ok | Same range (Bridgers), east side. |
| Brighton | Brighton (8790 ft) | 0.1 | good |  |
| Brundage | Brundage Reservoir (6280 ft) | 2.9 | good |  |
| Copper Mountain | Copper Mountain (10500 ft) | 1.4 | good |  |
| Crested Butte | Butte (10190 ft) | 0.7 | good |  |
| Crystal Mountain | Morse Lake (5400 ft) | 1.9 | good |  |
| Deer Valley | Thaynes Canyon (9260 ft) | 3.0 | ok | Next-door Park City Mountain, same ridge. |
| Diamond Peak | Marlette Lake (7860 ft) | 6.3 | ok | Same Carson Range crest above Lake Tahoe. |
| Discovery | Warm Springs (7840 ft) | 4.0 | ok |  |
| Eldora | Lake Eldora (9700 ft) | 0.4 | good |  |
| Grand Targhee | Grand Targhee (9260 ft) | 1.6 | good |  |
| Heavenly | Heavenly Valley (8540 ft) | 1.5 | good |  |
| Homewood | Ward Creek #3 (6750 ft) | 4.6 | ok | Next drainage north on Tahoe's west shore. |
| Hoodoo | Hogg Pass (4800 ft) | 1.1 | good |  |
| Kirkwood | Carson Pass (8360 ft) | 3.4 | good |  |
| Lee Canyon | Lee Canyon (8620 ft) | 0.1 | good |  |
| Lookout Pass | Lookout (5180 ft) | 0.4 | good |  |
| Loveland | Loveland Basin (11410 ft) | 0.5 | good |  |
| Mission Ridge | Grouse Camp (5390 ft) | 4.2 | ok | Mid-mountain height. Upper Wheeler is closer but sits at the base. |
| Monarch Mountain | Porphyry Creek (10790 ft) | 1.7 | good |  |
| Montana Snowbowl | Stuart Mountain (7270 ft) | 3.7 | ok | Near the summit, so it may read a little high for the whole mountain. |
| Mt. Hood Meadows | Mt Hood Test Site (5380 ft) | 2.6 | good |  |
| Mt. Rose | Mt Rose Ski Area (8810 ft) | 0.5 | good |  |
| Mt. Spokane | Quartz Peak (4710 ft) | 3.0 | ok |  |
| Palisades Tahoe | Palisades Tahoe (8010 ft) | 1.7 | good |  |
| Park City | Thaynes Canyon (9260 ft) | 2.3 | good |  |
| Powderhorn | Mesa Lakes (10160 ft) | 5.0 | ok | Same mesa (Grand Mesa), a little above the summit. |
| Purgatory | Cascade #2 (8990 ft) | 2.0 | good |  |
| Red Lodge Mountain | Cole Creek (7910 ft) | 0.5 | good |  |
| Red River | Red River Pass #2 (9840 ft) | 3.8 | ok |  |
| Schweitzer | Schweitzer Basin (6090 ft) | 0.9 | good |  |
| Sierra-at-Tahoe | Echo Peak (7650 ft) | 3.4 | ok |  |
| Sipapu | Tres Ritos (8740 ft) | 2.2 | ok |  |
| Ski Apache | Sierra Blanca (10250 ft) | 0.8 | good |  |
| Ski Santa Fe | Santa Fe (11480 ft) | 2.0 | good |  |
| Snowbird | Snowbird (9170 ft) | 1.0 | good |  |
| Solitude | Brighton (8790 ft) | 1.5 | good | Same canyon (Big Cottonwood). |
| Steamboat | Dry Lake (8240 ft) | 5.4 | ok | Same Park Range slope, just north of the ski area. |
| Stevens Pass | Stevens Pass (3940 ft) | 0.2 | good |  |
| Sugar Bowl | Css Lab (6890 ft) | 2.3 | good | UC Berkeley Central Sierra Snow Lab at Donner Summit. |
| Summit at Snoqualmie | Olallie Meadows (4010 ft) | 3.7 | ok |  |
| Sundance | Timpanogos Divide (8180 ft) | 2.9 | ok |  |
| Taos Ski Valley | Taos Powderhorn (11020 ft) | 1.0 | good |  |
| Timberline | Mt Hood Test Site (5380 ft) | 0.7 | good |  |
| Vail | Vail Mountain (10290 ft) | 1.6 | good |  |
| White Pass | Pigtail Peak (5800 ft) | 1.1 | good | Mid-mountain. White Pass E.S. sits at the base. |
| Wolf Creek | Wolf Creek Summit (10930 ft) | 0.7 | good |  |

## Next steps after your OK
1. Decide the weak matches (include with a note, or leave out).
2. Wire the station data into the study, month pages, best-resorts lists and best-time-to-ski pages; resorts without a station show "model estimate" and are kept out of rankings.
3. Later: "measured snow, last 24 hours" and "snowpack vs normal" on western resort pages from the same stations.
