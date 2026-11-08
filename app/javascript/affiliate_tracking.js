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

// Records email signups in PostHog (which page and which form), never the email address itself,
// so we can see which pages and offers turn visitors into subscribers.
document.addEventListener("submit", (event) => {
  const form = event.target
  if (!form || !form.action || !/\/subscribers/.test(form.action)) return
  if (!(window.posthog && window.posthog.capture)) return
  const magnet = form.querySelector('[name="subscriber[magnet]"]')
  const resort = form.querySelector('[name="subscriber[resort_id]"]')
  window.posthog.capture("email_signup", {
    page: window.location.pathname,
    form: (magnet && magnet.value) || (resort && resort.value ? "resort_alert" : "storm_alert")
  })
}, { capture: true })
