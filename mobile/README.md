# Snow Way iPhone app

A native shell (Capacitor 7) around https://snowway.app, with native push powder alerts. The site does all the
work: inside the app, `pwa.js` and `push_controller.js` detect `window.Capacitor` and use Apple's notifications.

- Bundle ID `app.snowway`, team Fast City LLC (`K36P898K34`), iOS 15+.
- Push: the app sends its APNs device token to `/push_subscriptions` (platform `ios`). The server sends with
  `app/services/apns.rb` once Railway has `APNS_KEY_P8` and `APNS_KEY_ID` (`APNS_ENV=development` for Xcode builds).

## Build and run
1. `cd mobile && npm install && npx cap sync ios`
2. Open `mobile/ios/App/App.xcodeproj` in Xcode, pick an iPhone simulator or your phone, press Run.
   (Projects on an iCloud-synced Desktop can fail code signing with "resource fork ... not allowed".
   If so, build with DerivedData outside Desktop, which is Xcode's default.)

## Ship to the App Store (Justin)
1. Install Xcode 26 (required for uploads since April 28, 2026). macOS 15.8 can run it.
2. Accept the Apple Developer Program License Agreement.
3. developer.apple.com > Certificates, IDs & Profiles > Keys: create a key with Apple Push Notifications service.
   Download the .p8 once. Put its text in Railway `APNS_KEY_P8` and its Key ID in `APNS_KEY_ID`.
4. App Store Connect > Apps > + : new iOS app, name "Snow Way: Ski Snow Forecasts", bundle ID `app.snowway`.
5. In Xcode: Product > Archive > Distribute App > App Store Connect. (Export switches push to production.)
6. Listing text, privacy answers and screenshots: `docs/app-store-listing.md`, `docs/store-assets/ios-6.9-*.png`.
