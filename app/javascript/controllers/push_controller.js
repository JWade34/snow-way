import { Controller } from "@hotwired/stimulus"

// Powder alerts as phone notifications (Web Push). Works in Chrome, Edge, Firefox and Android, in Safari on a Mac,
// and on iPhone once Snow Way is on the Home Screen (iOS 16.4+). iPhone visitors in Safari get the install steps instead.
// One device can follow several resorts; each alert is remembered in localStorage so the button shows "on".
export default class extends Controller {
  static targets = ["offer", "on", "blocked", "ios", "error", "button"]
  static values = { resortId: String, placement: String }

  connect() { this.refresh() }

  get key() { return `snowway_push:${this.resortIdValue || "all"}` }
  get vapid() { return document.querySelector('meta[name="vapid-public-key"]')?.content }
  get supported() { return "serviceWorker" in navigator && "PushManager" in window && "Notification" in window && !!this.vapid }
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
    if (!this.supported) {
      state = this.ios && !this.standalone && this.vapid ? "ios" : "none"
    } else if (Notification.permission === "denied") {
      state = "blocked"
    } else {
      const sub = await this.subscription().catch(() => null)
      if (!sub) localStorage.removeItem(this.key)
      state = sub && localStorage.getItem(this.key) && Notification.permission === "granted" ? "on" : "offer"
    }
    this.show(state)
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

  async enable() {
    this.capture("push_prompt_click")
    this.errorTargets.forEach((el) => el.classList.add("hidden"))
    this.busy(true)
    try {
      const permission = await Notification.requestPermission() // first, so Safari sees the tap
      this.capture("push_permission", { outcome: permission })
      if (permission !== "granted") return
      const reg = await navigator.serviceWorker.ready
      const sub = (await reg.pushManager.getSubscription()) ||
        (await reg.pushManager.subscribe({ userVisibleOnly: true, applicationServerKey: this.keyBytes(this.vapid) }))
      const res = await fetch("/push_subscriptions", {
        method: "POST", headers: this.headers(),
        body: JSON.stringify({ subscription: sub.toJSON(), resort_id: this.resortIdValue, threshold_inches: this.threshold,
                               page_path: window.location.pathname, standalone: this.standalone })
      })
      if (!res.ok) throw new Error(`save failed ${res.status}`)
      localStorage.setItem(this.key, "1")
      this.capture("push_subscribed", { threshold_inches: this.threshold })
    } catch (e) {
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
      const sub = await this.subscription()
      if (sub) {
        const res = await fetch("/push_subscriptions", { method: "DELETE", headers: this.headers(), body: JSON.stringify({ endpoint: sub.endpoint, resort_id: this.resortIdValue }) })
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
