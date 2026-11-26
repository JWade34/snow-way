// Snow Way service worker. Forecasts change all day, so pages always come from the network.
// The only thing cached is a small offline page, shown when the phone has no signal (common on a chairlift).
const OFFLINE_CACHE = "snowway-offline-v1"
const OFFLINE_URL = "/offline.html"

self.addEventListener("install", (event) => {
  event.waitUntil(caches.open(OFFLINE_CACHE).then((cache) => cache.add(new Request(OFFLINE_URL, { cache: "reload" }))))
  self.skipWaiting()
})

self.addEventListener("activate", (event) => {
  event.waitUntil(
    caches.keys().then((keys) => Promise.all(keys.filter((k) => k !== OFFLINE_CACHE).map((k) => caches.delete(k))))
      .then(() => self.clients.claim())
  )
})

self.addEventListener("fetch", (event) => {
  if (event.request.mode !== "navigate") return
  event.respondWith(fetch(event.request).catch(() => caches.match(OFFLINE_URL)))
})

// Powder alert notifications. The server sends { title, body, url, tag }.
self.addEventListener("push", (event) => {
  let data = {}
  try { data = event.data ? event.data.json() : {} } catch (_) { data = { body: event.data && event.data.text() } }
  event.waitUntil(self.registration.showNotification(data.title || "Snow Way powder alert", {
    body: data.body || "",
    icon: "/icons/icon-192.png",
    badge: "/icons/icon-192.png",
    tag: data.tag || "powder",
    renotify: true,
    data: { url: data.url || "/" }
  }))
})

// Tapping a notification opens its page, reusing an open Snow Way window when there is one.
self.addEventListener("notificationclick", (event) => {
  event.notification.close()
  const url = new URL((event.notification.data && event.notification.data.url) || "/", self.location.origin).href
  event.waitUntil(clients.matchAll({ type: "window", includeUncontrolled: true }).then((wins) => {
    const win = wins.find((w) => new URL(w.url).origin === self.location.origin)
    if (win) return win.focus().then((w) => (w || win).navigate(url))
    return clients.openWindow(url)
  }))
})
