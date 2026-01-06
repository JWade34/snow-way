import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["number"]
  static values = { target: Number }

  connect() {
    this.animateCounter()
  }

  animateCounter() {
    const target = this.targetValue
    const duration = 2000
    const start = 0
    const startTime = performance.now()

    const animate = (currentTime) => {
      const elapsed = currentTime - startTime
      const progress = Math.min(elapsed / duration, 1)

      // Ease out cubic
      const easeOut = 1 - Math.pow(1 - progress, 3)
      const current = start + (target - start) * easeOut

      this.numberTarget.textContent = current.toFixed(1)

      if (progress < 1) {
        requestAnimationFrame(animate)
      }
    }

    requestAnimationFrame(animate)
  }
}
