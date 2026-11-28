import { Controller } from "@hotwired/stimulus"

// Powder alerts as phone notifications (Web Push). Works in Chrome, Edge, Firefox and Android, in Safari on a Mac,
// and on iPhone once Snow Way is on the Home Screen (iOS 16.4+). iPhone visitors in Safari get the install steps instead.
// Inside the Snow Way iPhone app it uses Apple's native notifications (Capacitor PushNotifications) instead.
// One device can follow several resorts; each alert is remembered in localStorage so the button shows "on".
export default class extends Controller {
  static targets = ["offer", "on", "blocked", "ios", "error", "button", "deals"]
  static values = { resortId: String, placement: String, crewToken: String }

  connect() { this.refresh() }

  get key() { return this.crewTokenValue ? `snowway_push:crew:${this.crewTokenValue}` : `snowway_push:${this.resortIdValue || "all"}` }
  get vapid() { return document.querySelector('meta[name="vapid-public-key"]')?.content }
  get native() { return window.Capacitor?.isNativePlatform?.() ? window.Capacitor.Plugins.PushNotifications : null }
  get apns() { return !!document.querySelector('meta[name="apns-enabled"]') }
  get supported() {
    if (this.native) return this.apns
    return "serviceWorker" in navigator && "PushManager" in window && "Notification" in window && !!this.vapid
  }
  get standalone() { return !!window.snowwayApp?.standalone?.() }
  get ios() {
    const ua = navigator.userAgent
    return /iPhone|iPad|iPod/.test(ua) || (ua.includes("Macintosh") && navigator.maxTouchPoints > 1)
  }

  capture(event, props = {}) {
    window.posthog?.capture?.(event, { page: window.location.pathname, placement: this.placementValue, resort_id: this.resortIdValue || null, standalone: this.standalone, ...props })
  }

  async subscription() {
    const reg = await navigator.serviceWorker.getRegistration()
    return reg ? reg.pushManager.getSubscription() : null
  }

  async refresh() {
    let state = "none"
    if (this.native && this.supported) {
      const { receive } = await this.native.checkPermissions().catch(() => ({ receive: "prompt" }))
      state = receive === "denied" ? "blocked" : (receive === "granted" && localStorage.getItem(this.key) ? "on" : "offer")
    } else if (this.native) {
      state = "none"
    } else if (!this.supported) {
      state = this.ios && !this.standalone && this.vapid ? "ios" : "none"
    } else if (Notification.permission === "denied") {
      state = "blocked"
    } else {
      const sub = await this.subscription().catch(() => null)
      if (!sub) localStorage.removeItem(this.key)
      state = sub && localStorage.getItem(this.key) && Notification.permission === "granted" ? "on" : "offer"
    }
    this.show(state)
    this.dealsTargets.forEach((box) => { box.checked = localStorage.getItem("snowway_push_deals") === "1" })
  }

  // The push address this device registered with (APNs token in the iPhone app, Web Push endpoint elsewhere).
  async endpoint() {
    if (this.native) return localStorage.getItem("snowway_apns_token")
    return (await this.subscription().catch(() => null))?.endpoint
  }

  // Gear deal notifications are their own opt-in, separate from powder alerts.
  async toggleDeals(event) {
    const on = event.target.checked
    const endpoint = await this.endpoint()
    if (!endpoint) { event.target.checked = false; return }
    window.snowwayApp?.haptic?.("selection")
    const res = await fetch("/push_subscriptions/settings", { method: "PATCH", headers: this.headers(), body: JSON.stringify({ endpoint, deals: on }) }).catch(() => null)
    if (!res?.ok) { event.target.checked = !on; return }
    on ? localStorage.setItem("snowway_push_deals", "1") : localStorage.removeItem("snowway_push_deals")
    this.capture(on ? "push_deals_on" : "push_deals_off")
  }

  show(state) {
    const map = { offer: this.offerTargets, on: this.onTargets, blocked: this.blockedTargets, ios: this.iosTargets }
    Object.entries(map).forEach(([name, els]) => els.forEach((el) => el.classList.toggle("hidden", name !== state)))
    this.element.classList.toggle("hidden", state === "none")
  }

  busy(on) { this.buttonTargets.forEach((b) => { b.disabled = on; b.classList.toggle("opacity-60", on) }) }

  get threshold() {
    const select = this.element.closest("section")?.querySelector("select[name='subscriber[threshold_inches]']")
    return select?.value || "6"
  }

  headers() {
    return { "Content-Type": "application/json", Accept: "application/json", "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]')?.content || "" }
  }

  // Asks iOS for permission, registers with APNs, and returns the device token.
  async nativeToken() {
    const { receive } = await this.native.requestPermissions()
    this.capture("push_permission", { outcome: receive })
    if (receive !== "granted") return null
    return new Promise((resolve, reject) => {
      const handles = []
      const done = (fn, value) => { handles.forEach((h) => h.then((x) => x.remove())); fn(value) }
      handles.push(this.native.addListener("registration", (t) => done(resolve, t.value)))
      handles.push(this.native.addListener("registrationError", (e) => done(reject, new Error(e?.error || "registration failed"))))
      this.native.register()
      setTimeout(() => done(reject, new Error("registration timed out")), 15000)
    })
  }

  save(body) {
    return fetch("/push_subscriptions", {
      method: "POST", headers: this.headers(),
      body: JSON.stringify({ resort_id: this.resortIdValue, crew_token: this.crewTokenValue || undefined, threshold_inches: this.threshold, page_path: window.location.pathname, standalone: this.standalone, ...body })
    }).then((res) => { if (!res.ok) throw new Error(`save failed ${res.status}`) })
  }

  async enable() {
    this.capture("push_prompt_click")
    this.errorTargets.forEach((el) => el.classList.add("hidden"))
    this.busy(true)
    try {
      if (this.native) {
        const token = await this.nativeToken()
        if (!token) return
        await this.save({ platform: "ios", subscription: { endpoint: token } })
        localStorage.setItem("snowway_apns_token", token)
        localStorage.setItem(this.key, "1")
        window.snowwayApp?.haptic?.("success")
        window.snowwayApp?.native?.("requestReview")
        this.capture("push_subscribed", { threshold_inches: this.threshold, platform: "ios" })
        return
      }
      const permission = await Notification.requestPermission() // first, so Safari sees the tap
      this.capture("push_permission", { outcome: permission })
      if (permission !== "granted") return
      const reg = await navigator.serviceWorker.ready
      const sub = (await reg.pushManager.getSubscription()) ||
        (await reg.pushManager.subscribe({ userVisibleOnly: true, applicationServerKey: this.keyBytes(this.vapid) }))
      await this.save({ subscription: sub.toJSON() })
      localStorage.setItem(this.key, "1")
      this.capture("push_subscribed", { threshold_inches: this.threshold })
    } catch (e) {
      window.snowwayApp?.haptic?.("error")
      this.capture("push_error", { message: String(e?.message || e).slice(0, 120) })
      this.errorTargets.forEach((el) => el.classList.remove("hidden"))
    } finally {
      this.busy(false)
      this.refresh()
    }
  }

  async disable() {
    this.busy(true)
    try {
      const token = this.native && localStorage.getItem("snowway_apns_token")
      const sub = this.native ? null : await this.subscription()
      if (token) {
        await fetch("/push_subscriptions", { method: "DELETE", headers: this.headers(), body: JSON.stringify({ endpoint: token, resort_id: this.resortIdValue, crew_token: this.crewTokenValue || undefined }) })
      } else if (sub) {
        const res = await fetch("/push_subscriptions", { method: "DELETE", headers: this.headers(), body: JSON.stringify({ endpoint: sub.endpoint, resort_id: this.resortIdValue, crew_token: this.crewTokenValue || undefined }) })
        const { remaining } = res.ok ? await res.json() : { remaining: 1 }
        if (remaining === 0) await sub.unsubscribe()
      }
      localStorage.removeItem(this.key)
      this.capture("push_unsubscribed")
    } finally {
      this.busy(false)
      this.refresh()
    }
  }

  keyBytes(base64url) {
    const padded = (base64url + "=".repeat((4 - (base64url.length % 4)) % 4)).replace(/-/g, "+").replace(/_/g, "/")
    return Uint8Array.from(atob(padded), (c) => c.charCodeAt(0))
  }
}
