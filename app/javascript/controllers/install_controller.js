import { Controller } from "@hotwired/stimulus"

// "Get the app" buttons. Chrome and Android show the browser's own install dialog. iPhone and iPad (where
// Safari has no install dialog) go to /app for the two-tap Add to Home Screen steps. Hidden once installed.
export default class extends Controller {
  static targets = ["button", "ios"]
  static values = { placement: String }

  connect() {
    this.refresh = this.refresh.bind(this)
    document.addEventListener("snowway:installable", this.refresh)
    document.addEventListener("snowway:installed", this.refresh)
    this.refresh()
  }

  disconnect() {
    document.removeEventListener("snowway:installable", this.refresh)
    document.removeEventListener("snowway:installed", this.refresh)
  }

  get app() { return window.snowwayApp || { prompt: null, standalone: () => false } }

  get ios() {
    const ua = navigator.userAgent
    return /iPhone|iPad|iPod/.test(ua) || (ua.includes("Macintosh") && navigator.maxTouchPoints > 1)
  }

  refresh() {
    const show = !this.app.standalone() && (this.app.prompt || this.ios)
    this.buttonTargets.forEach((b) => b.classList.toggle("hidden", !show))
    this.iosTargets.forEach((el) => el.classList.toggle("hidden", !(this.ios && !this.app.standalone())))
  }

  async install(event) {
    const prompt = this.app.prompt
    window.posthog?.capture?.("app_install_click", { page: window.location.pathname, placement: this.placementValue, prompt: !!prompt })
    if (!prompt) return // falls through to the link's href (/app) on iPhone
    event.preventDefault()
    prompt.prompt()
    const { outcome } = await prompt.userChoice
    window.posthog?.capture?.("app_install_choice", { outcome, placement: this.placementValue })
    window.snowwayApp.prompt = null
    this.refresh()
  }
}
