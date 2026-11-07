import { Controller } from "@hotwired/stimulus"

// Site-wide Powder Calendar bar. Stays out of the way: appears only after the visitor has read
// a good chunk of the page (45% scroll) or spent 30 seconds, and never again once dismissed.
export default class extends Controller {
  static values = { key: String }

  connect() {
    let dismissed = false
    try { dismissed = window.localStorage.getItem(this.keyValue) === "1" } catch (_) {}
    if (dismissed) return
    this.onScroll = () => {
      const max = document.documentElement.scrollHeight - window.innerHeight
      if (max <= 0 || window.scrollY / max > 0.45) this.show()
    }
    window.addEventListener("scroll", this.onScroll, { passive: true })
    this.timer = setTimeout(() => this.show(), 30000)
  }

  disconnect() {
    this.cleanup()
  }

  show() {
    this.element.hidden = false
    this.cleanup()
  }

  cleanup() {
    if (this.onScroll) window.removeEventListener("scroll", this.onScroll)
    clearTimeout(this.timer)
  }

  dismiss() {
    this.element.hidden = true
    try { window.localStorage.setItem(this.keyValue, "1") } catch (_) {}
  }
}
