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

// iPhone app only: native features through Capacitor (Haptics plugin and the app's own SnowWay plugin).
// Both helpers do nothing on the website.
const plugins = () => (nativeApp() ? window.Capacitor.Plugins : {})
window.snowwayApp.native = (method, args = {}) => plugins().SnowWay?.[method]?.(args)?.catch?.(() => {})
window.snowwayApp.haptic = (kind = "light") => {
  const h = plugins().Haptics
  if (!h) return
  if (kind === "success" || kind === "error" || kind === "warning") return h.notification({ type: kind.toUpperCase() }).catch(() => {})
  if (kind === "selection") return h.selectionChanged().catch(() => {})
  h.impact({ style: kind === "medium" ? "MEDIUM" : "LIGHT" }).catch(() => {})
}

if (nativeApp() && !window.snowwayApp.listening) {
  window.snowwayApp.listening = true
  const { PushNotifications } = window.Capacitor.Plugins
  // A tapped notification opens its page. "Places to stay" on a powder alert opens the lodging page instead.
  PushNotifications?.addListener("pushNotificationActionPerformed", (action) => {
    const data = action?.notification?.data || {}
    const url = action.actionId === "stay" && data.stay_url ? data.stay_url : data.url
    capture("push_opened", { action: action.actionId, url })
    if (url && url.startsWith("/")) window.location.href = url
  })
  // Light taps on buttons and toggles, the way native iPhone apps feel. Links stay silent.
  document.addEventListener("click", (e) => {
    if (e.target.closest?.("button, [data-haptic], summary")) window.snowwayApp.haptic(e.target.closest("[data-haptic]")?.dataset.haptic || "light")
  }, { passive: true })
  document.addEventListener("change", (e) => { if (e.target.matches?.("select, input[type=checkbox], input[type=radio]")) window.snowwayApp.haptic("selection") })
  // Email signup worked: a success tap, and a good moment to ask for an App Store rating (Apple limits how often it shows).
  document.addEventListener("turbo:submit-end", (e) => {
    if (e.detail?.success && e.target?.action?.includes("/subscribers")) { window.snowwayApp.haptic("success"); window.snowwayApp.native("requestReview") }
  })
  // Opening the app clears the red badge. Each resort page tells iOS about the visit, so Siri Suggestions and
  // Spotlight can offer that resort, and the home screen widget can default to it.
  const visit = () => {
    window.snowwayApp.native("clearBadge")
    const m = window.location.pathname.match(/^\/resorts\/([a-z0-9-]+)\/?$/)
    const name = document.querySelector("h1")?.firstChild?.textContent?.trim() // "Vail" (the subtitle is a child span)
    if (m && name) window.snowwayApp.native("viewedResort", { slug: m[1], name: name.slice(0, 60) })
  }
  document.addEventListener("turbo:load", visit)
  document.addEventListener("visibilitychange", () => { if (document.visibilityState === "visible") window.snowwayApp.native("clearBadge") })
}

if (standalone()) {
  window.posthog?.register?.({ app_mode: nativeApp() ? "ios_app" : "standalone" })
  if (!sessionStorage.getItem("snowway_app_open")) {
    sessionStorage.setItem("snowway_app_open", "1")
    capture("app_open")
  }
}
