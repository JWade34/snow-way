// Makes snowway.app installable as an app. Registers the service worker, keeps the browser's install prompt
// for the "Get the app" buttons, and tells PostHog when the site is opened as an installed app.
// Inside the Snow Way iPhone app (Capacitor shell), the site counts as installed too.
const nativeApp = () => !!window.Capacitor?.isNativePlatform?.()
const standalone = () => nativeApp() || window.matchMedia("(display-mode: standalone)").matches || window.navigator.standalone === true
const capture = (event, props = {}) => window.posthog?.capture?.(event, { page: window.location.pathname, ...props })

window.snowwayApp = { prompt: null, standalone, nativeApp }

if ("serviceWorker" in navigator) {
  window.addEventListener("load", () => navigator.serviceWorker.register("/service-worker.js", { scope: "/" }).catch(() => {}))
}

window.addEventListener("beforeinstallprompt", (event) => {
  event.preventDefault()
  window.snowwayApp.prompt = event
  document.dispatchEvent(new CustomEvent("snowway:installable"))
})

window.addEventListener("appinstalled", () => {
  window.snowwayApp.prompt = null
  capture("app_installed")
  document.dispatchEvent(new CustomEvent("snowway:installed"))
})

// A tapped notification in the iPhone app opens its page.
if (nativeApp() && !window.snowwayApp.listening) {
  window.snowwayApp.listening = true
  window.Capacitor.Plugins.PushNotifications?.addListener("pushNotificationActionPerformed", (action) => {
    const url = action?.notification?.data?.url
    if (url && url.startsWith("/")) window.location.href = url
  })
}

if (standalone()) {
  window.posthog?.register?.({ app_mode: nativeApp() ? "ios_app" : "standalone" })
  if (!sessionStorage.getItem("snowway_app_open")) {
    sessionStorage.setItem("snowway_app_open", "1")
    capture("app_open")
  }
}
