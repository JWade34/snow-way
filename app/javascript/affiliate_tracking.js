// Records clicks on affiliate links (rel="sponsored") so the admin can show which pages earn.
// Sends page path, link URL, and link text only. No cookies or personal data.
document.addEventListener("click", (event) => {
  const link = event.target.closest && event.target.closest('a[rel~="sponsored"]')
  if (!link) return
  const data = new FormData()
  data.append("page", window.location.pathname)
  data.append("href", link.href)
  data.append("label", (link.textContent || "").trim().slice(0, 120))
  if (navigator.sendBeacon) navigator.sendBeacon("/t/a", data)
  if (window.posthog && window.posthog.capture) {
    window.posthog.capture("affiliate_click", { page: window.location.pathname, href: link.href, label: data.get("label") })
  }
}, { capture: true })
