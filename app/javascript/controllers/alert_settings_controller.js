import { Controller } from "@hotwired/stimulus"

// The Alerts and settings page: pass choice (kept on the device) and what this device's notifications include.
export default class extends Controller {
  static targets = ["pass", "off", "on", "offer", "list", "weekly", "deals"]

  connect() {
    this.markPass(localStorage.getItem("snowway_pass"))
    this.load()
  }

  headers() {
    return { "Content-Type": "application/json", Accept: "application/json", "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]')?.content || "" }
  }

  async endpoint() {
    if (window.Capacitor?.isNativePlatform?.()) return localStorage.getItem("snowway_apns_token")
    if (!("serviceWorker" in navigator)) return null
    const reg = await navigator.serviceWorker.getRegistration().catch(() => null)
    return (await reg?.pushManager?.getSubscription().catch(() => null))?.endpoint || null
  }

  pickPass(event) {
    const pass = event.currentTarget.dataset.pass
    localStorage.setItem("snowway_pass", pass)
    this.markPass(pass)
    window.snowwayApp?.native?.("setPass", { pass })
    window.posthog?.capture?.("pass_picked", { pass, placement: "settings" })
  }

  markPass(pass) { this.passTargets.forEach((b) => b.setAttribute("aria-pressed", String(b.dataset.pass === pass))) }

  async load() {
    this.ep = await this.endpoint()
    const data = this.ep ? await fetch(`/push_subscriptions?endpoint=${encodeURIComponent(this.ep)}`, { headers: this.headers() }).then((r) => r.json()).catch(() => null) : null
    const on = !!data?.alerts?.length
    this.offTarget.classList.toggle("hidden", on)
    this.onTarget.classList.toggle("hidden", !on)
    this.offerTarget.classList.toggle("hidden", on)
    if (!on) return
    this.weeklyTarget.checked = data.weekly
    this.dealsTarget.checked = data.deals
    this.listTarget.replaceChildren(...data.alerts.map((a) => this.row(a)))
  }

  row(alert) {
    const li = document.createElement("li")
    li.className = "flex items-center justify-between gap-3 rounded-lg bg-slate-800/50 border border-slate-700 px-4 py-3"
    const label = document.createElement("span")
    label.className = "font-semibold"
    label.textContent = alert.crew_token ? alert.label : `${alert.label}${alert.threshold_inches ? ` (${alert.threshold_inches}"+)` : ""}`
    const off = document.createElement("button")
    off.type = "button"
    off.className = "text-slate-400 hover:text-white underline underline-offset-2 cursor-pointer py-2"
    off.textContent = "Turn off"
    off.addEventListener("click", () => this.remove(alert))
    li.append(label, off)
    return li
  }

  async remove(alert) {
    await fetch("/push_subscriptions", { method: "DELETE", headers: this.headers(), body: JSON.stringify({ endpoint: this.ep, resort_id: alert.resort_id, crew_token: alert.crew_token }) }).catch(() => null)
    const key = alert.crew_token ? `snowway_push:crew:${alert.crew_token}` : `snowway_push:${alert.resort_id || "all"}`
    localStorage.removeItem(key)
    window.posthog?.capture?.("push_unsubscribed", { placement: "settings" })
    this.load()
  }

  async toggle(event) {
    const box = event.currentTarget
    const res = await fetch("/push_subscriptions/settings", { method: "PATCH", headers: this.headers(), body: JSON.stringify({ endpoint: this.ep, [box.dataset.setting]: box.checked }) }).catch(() => null)
    if (!res?.ok) { box.checked = !box.checked; return }
    if (box.dataset.setting === "deals") box.checked ? localStorage.setItem("snowway_push_deals", "1") : localStorage.removeItem("snowway_push_deals")
    window.posthog?.capture?.(`push_${box.dataset.setting}_${box.checked ? "on" : "off"}`, { placement: "settings" })
  }
}
