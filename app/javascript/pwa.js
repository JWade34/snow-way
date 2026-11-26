// Makes snowway.app installable as an app. Registers the service worker, keeps the browser's install prompt
// for the "Get the app" buttons, and tells PostHog when the site is opened as an installed app.
const standalone = () => window.matchMedia("(display-mode: standalone)").matches || window.navigator.standalone === true
const capture = (event, props = {}) => window.posthog?.capture?.(event, { page: window.location.pathname, ...props })

window.snowwayApp = { prompt: null, standalone }

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

if (standalone()) {
  window.posthog?.register?.({ app_mode: "standalone" })
  if (!sessionStorage.getItem("snowway_app_open")) {
    sessionStorage.setItem("snowway_app_open", "1")
    capture("app_open")
  }
}
