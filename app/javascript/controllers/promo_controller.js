import { Controller } from "@hotwired/stimulus"

// Site-wide Powder Calendar bar. Hidden until JS confirms it wasn't dismissed, so it never flashes.
export default class extends Controller {
  static values = { key: String }

  connect() {
    let dismissed = false
    try { dismissed = window.localStorage.getItem(this.keyValue) === "1" } catch (_) {}
    if (!dismissed) this.element.hidden = false
  }

  dismiss() {
    this.element.hidden = true
    try { window.localStorage.setItem(this.keyValue, "1") } catch (_) {}
  }
}
