import { Controller } from "@hotwired/stimulus"

// Phone booking bar: shows after the first screen, hides while a form field has focus
// or the powder-alert form is on screen, so it never covers what the visitor is doing.
export default class extends Controller {
  connect() {
    this.typing = false
    this.alertVisible = false
    this.onScroll = () => this.update()
    this.onFocus = (e) => { if (e.target.matches("input, textarea, select")) { this.typing = true; this.update() } }
    this.onBlur = () => { this.typing = false; this.update() }
    window.addEventListener("scroll", this.onScroll, { passive: true })
    document.addEventListener("focusin", this.onFocus)
    document.addEventListener("focusout", this.onBlur)
    const form = document.getElementById("alert-form")
    if (form && "IntersectionObserver" in window) {
      this.observer = new IntersectionObserver(([entry]) => { this.alertVisible = entry.isIntersecting; this.update() })
      this.observer.observe(form)
    }
    this.update()
  }

  disconnect() {
    window.removeEventListener("scroll", this.onScroll)
    document.removeEventListener("focusin", this.onFocus)
    document.removeEventListener("focusout", this.onBlur)
    this.observer?.disconnect()
  }

  update() {
    this.element.hidden = window.scrollY < window.innerHeight * 0.6 || this.typing || this.alertVisible
  }
}
