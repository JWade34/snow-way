import { Controller } from "@hotwired/stimulus"

// Invite buttons on a crew page: text the group, the share sheet, or copy the link.
export default class extends Controller {
  static targets = ["share", "copyLabel"]
  static values = { url: String, text: String }

  connect() {
    if (navigator.share) this.shareTargets.forEach((b) => b.classList.remove("hidden"))
  }

  capture(method) { window.posthog?.capture?.("crew_invite", { method, page: window.location.pathname }) }

  track(event) { this.capture(event.currentTarget.dataset.method) }

  async share() {
    this.capture("share_sheet")
    try { await navigator.share({ title: document.title, text: this.textValue.replace(this.urlValue, "").trim(), url: this.urlValue }) } catch (_) {}
  }

  async copy() {
    this.capture("copy")
    try {
      await navigator.clipboard.writeText(this.urlValue)
      this.copyLabelTarget.textContent = "Copied"
      window.snowwayApp?.haptic?.("success")
      setTimeout(() => { this.copyLabelTarget.textContent = "Copy link" }, 2000)
    } catch (_) { this.copyLabelTarget.textContent = this.urlValue }
  }
}
