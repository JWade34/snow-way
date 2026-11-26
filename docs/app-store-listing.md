# Snow Way app store listings

Copy, form answers and assets for Google Play and the Apple App Store. Written 2026-11-26 from what the
site actually collects (see /privacy). Change the answers here if the site starts collecting something new.

## Shared basics

- **App name:** Snow Way: Ski Snow Forecasts (28 characters; Play and Apple allow 30)
- **Developer / seller:** Fast City LLC
- **Category:** Weather (Play and Apple). Second choice on Apple: Sports.
- **Price:** Free. No in-app purchases.
- **Website:** https://snowway.app
- **Privacy policy:** https://snowway.app/privacy
- **Support URL (Apple):** https://snowway.app/about
- **Contact email:** Justin to choose (shown publicly on the listing).
- **Android package name:** `app.snowway` (already set in `/.well-known/assetlinks.json`)
- **iOS bundle ID (later):** `app.snowway`

## Google Play listing

**Short description** (80 max):
> Ski resorts ranked by the next 7 days of snow. Forecasts and powder alerts.

**Full description** (4,000 max):
> Find the ski resort getting the most snow. Snow Way ranks 214 ski resorts in North America, Japan, Europe and the Southern Hemisphere by the next 7 days of forecast snow, so you know where the powder is before you book.
>
> WHAT YOU GET
> • Powder rankings: every resort ranked by forecast snow, updated through the day
> • 7-day and 14-day snow forecasts for each resort, base and summit
> • Powder alerts: a notification when a big storm lines up at your resort
> • Where it's snowing right now, and a weekly powder report
> • Ikon vs Epic: which pass's resorts are getting more snow
> • Lift ticket prices, where to stay, and how to get there for popular resorts
> • Powder odds: the months each resort gets new snow most often, from USDA snow station data
>
> FREE, NO ACCOUNT
> Every forecast and guide is free. There's no account to make. Turn on powder alerts with one tap.
>
> WORKS ON THE MOUNTAIN
> If you lose signal on the chairlift, Snow Way shows a no-signal page instead of an error.
>
> Forecasts come from weather models and change, especially beyond a few days. Always check the resort's own snow report before you drive.

**Tags / category:** Weather. Add tags: Skiing, Snowboarding, Weather forecast.

## Google Play forms

### Data safety
Answer "Yes, we collect data". Data is encrypted in transit: **Yes**. Users can ask for deletion: **Yes** (contact on /privacy).

| Data type | Collected | Shared | Optional? | Why |
|---|---|---|---|---|
| Personal info > Email address | Yes | No | Optional | App functionality (powder alert and weekly emails), Developer communications |
| App activity > App interactions (page views, taps) | Yes | No | Required | Analytics |
| App info and performance > Crash logs / Diagnostics | No | | | |
| Location > Approximate location | Yes | No | Required | Analytics (PostHog estimates it from the IP address) |
| Location > Precise location | No (used on the device only to sort nearby resorts, never sent) | | | |
| Device or other IDs | Yes | No | Required | Analytics (PostHog's anonymous browser ID) |

Notes:
- Push notification addresses aren't a listed data type. They contain no personal info.
- "Shared" means sent to a third party for its own use. PostHog and Resend are service providers acting for us, which Google says is not sharing.
- Affiliate links open the store's own site; that site collects its own data under its own policy.

### Content rating (IARC questionnaire)
Category: Reference, news or educational (or Utility). Answer **No** to violence, sexuality, language,
controlled substances, gambling, user-to-user interaction, sharing location with other users, and digital purchases.
Expected rating: Everyone / PEGI 3.

### Target audience
18 and over. (Choosing under-13 ages pulls in Google's Families policy, which this app doesn't need.)

### Ads
"Does your app contain ads?" **No.** Snow Way has affiliate links (Amazon, Stay22 hotel links) but no ad
network or ad SDK. If Google's reviewer disagrees, switch to Yes; it doesn't change anything else.

### App access
All functionality is available without login.

### News app / COVID / government / financial features
No to all.

## Apple App Store (later, after the native build)

**Subtitle** (30 max): Powder rankings and alerts
**Promotional text** (170 max): Big storm coming? Snow Way ranks 214 ski resorts by the next 7 days of snow and sends a powder alert when your resort is about to get hit.
**Keywords** (100 max, commas, no spaces): ski,snow,forecast,powder,snow report,resort,snowboard,epic,ikon,weather,alerts,opensnow
  (Drop "opensnow" if Apple rejects competitor names.)
**Description:** same as the Play full description.

### App Privacy ("nutrition label")
- Contact Info > Email Address: collected, linked to the user (it is their email), not used for tracking. Purpose: App Functionality.
- Usage Data > Product Interaction: collected, not linked to identity, not used for tracking. Purpose: Analytics.
- Identifiers > Device ID: collected, not linked, not for tracking. Purpose: Analytics.
- Location > Coarse Location: collected, not linked, not for tracking. Purpose: Analytics.
- Tracking: **No.** (No data is combined with other companies' data for ads.)

## Assets

In `docs/store-assets/`:
- `play-icon-512.png`: 512x512 icon
- `play-feature-graphic.png`: 1024x500 feature graphic
- `play-phone-*.png`: 1080x1920 phone screenshots (Play needs 2 to 8, ratio no more than 2:1)
- `ios-6.9-*.png`: 1320x2868 iPhone screenshots for the App Store (6.9" display size)
