import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container"]

  connect() {
    this.snowflakes = []
    // Respect "reduce motion", and keep phones light: fewer, smaller flakes.
    if (window.matchMedia("(prefers-reduced-motion: reduce)").matches) return
    this.small = window.innerWidth < 640
    this.createSnowflakes()
  }

  disconnect() {
    clearInterval(this.interval)
    this.snowflakes.forEach(flake => flake.remove())
  }

  createSnowflakes() {
    const count = this.small ? 18 : 50
    this.max = this.small ? 24 : 60

    for (let i = 0; i < count; i++) {
      setTimeout(() => {
        this.createSnowflake()
      }, i * 100)
    }

    // Keep creating new snowflakes
    this.interval = setInterval(() => {
      if (this.snowflakes.length < this.max) {
        this.createSnowflake()
      }
    }, 500)
  }

  createSnowflake() {
    const flake = document.createElement("div")
    const size = Math.random() * (this.small ? 6 : 8) + 4
    const startX = Math.random() * 100
    const duration = Math.random() * 10 + 10
    const delay = Math.random() * 5

    flake.innerHTML = "&#10052;"
    flake.style.cssText = `
      position: fixed;
      top: -20px;
      left: ${startX}%;
      font-size: ${size}px;
      color: rgba(255, 255, 255, ${Math.random() * (this.small ? 0.35 : 0.5) + 0.15});
      animation: snowfall ${duration}s linear ${delay}s infinite;
      pointer-events: none;
      z-index: 1;
    `

    this.containerTarget.appendChild(flake)
    this.snowflakes.push(flake)

    // Remove old snowflakes if too many
    if (this.snowflakes.length > this.max + 10) {
      const old = this.snowflakes.shift()
      old.remove()
    }
  }
}
