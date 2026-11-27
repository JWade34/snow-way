# Snow Way iPhone app

A native shell (Capacitor 7) around https://snowway.app, with native push powder alerts. The site does all the
work: inside the app, `pwa.js` and `push_controller.js` detect `window.Capacitor` and use Apple's notifications.

- Bundle ID `app.snowway`, team Fast City LLC (`K36P898K34`), iOS 16+ (widgets need iOS 17).
- Push: the app sends its APNs device token to `/push_subscriptions` (platform `ios`). The server sends with
  `app/services/apns.rb` once Railway has `APNS_KEY_P8` and `APNS_KEY_ID` (`APNS_ENV=development` for Xcode builds).

## Native features
- **Notifications** (`apns.rb`, `AppDelegate.swift`): subtitle, badge, a forecast picture (the `NotificationService`
  extension, bundle `app.snowway.notifications`), "See forecast" and "Places to stay" buttons, and
  time-sensitive delivery for storms of 18"+ (breaks through Focus). Gear deals are a separate opt-in, sent quietly
  (passive) with `bin/rails push:deal TITLE=... BODY=... URL=/...` (add `DRY_RUN=1` to count devices first).
- **Haptics** (`@capacitor/haptics`, `pwa.js`): light taps on buttons, a tick on toggles, success and error buzzes.
- **Siri and Shortcuts** (`SnowWayIntents.swift`): "Where's the powder in Snow Way", "How much snow is Alta getting
  in Snow Way", "Open Vail in Snow Way". No setup; they also appear in the Shortcuts app and the Action button.
- **Widgets** (`SnowWayWidget`, bundle `app.snowway.widget`): Powder Now and My Resort, on the Home Screen and
  Lock Screen. They read `/api/app/...` on snowway.app.
- **Spotlight and Siri Suggestions** (`SnowWayPlugin.viewedResort`): resorts you open show up in iPhone search.
- **App Store rating prompt** (`SnowWayPlugin.requestReview`): after a signup or turning on alerts, from the 3rd
  session on, at most once every 4 months. Apple decides whether it actually shows.

## Build and run
1. `cd mobile && npm install && npx cap sync ios`
2. Open `mobile/ios/App/App.xcodeproj` in Xcode, pick an iPhone simulator or your phone, press Run.
   (Projects on an iCloud-synced Desktop can fail code signing with "resource fork ... not allowed".
   If so, build with DerivedData outside Desktop, which is Xcode's default.)

## Ship to the App Store (Justin)
First time: in Xcode, select each target (App, SnowWayWidget, NotificationService) > Signing & Capabilities, and
make sure the team is Fast City LLC with "Automatically manage signing" on. Xcode registers the two extension IDs
and the Time Sensitive Notifications capability itself.
1. Install Xcode 26 (required for uploads since April 28, 2026). macOS 15.8 can run it.
2. Accept the Apple Developer Program License Agreement.
3. developer.apple.com > Certificates, IDs & Profiles > Keys: create a key with Apple Push Notifications service.
   Download the .p8 once. Put its text in Railway `APNS_KEY_P8` and its Key ID in `APNS_KEY_ID`.
4. App Store Connect > Apps > + : new iOS app, name "Snow Way: Ski Snow Forecasts", bundle ID `app.snowway`.
5. In Xcode: Product > Archive > Distribute App > App Store Connect. (Export switches push to production.)
6. Listing text, privacy answers and screenshots: `docs/app-store-listing.md`, `docs/store-assets/ios-6.9-*.png`.
