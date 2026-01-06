import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container"]

  connect() {
    this.snowflakes = []
    this.createSnowflakes()
  }

  disconnect() {
    this.snowflakes.forEach(flake => flake.remove())
  }

  createSnowflakes() {
    const count = 50

    for (let i = 0; i < count; i++) {
      setTimeout(() => {
        this.createSnowflake()
      }, i * 100)
    }

    // Keep creating new snowflakes
    this.interval = setInterval(() => {
      if (this.snowflakes.length < 60) {
        this.createSnowflake()
      }
    }, 500)
  }

  createSnowflake() {
    const flake = document.createElement("div")
    const size = Math.random() * 8 + 4
    const startX = Math.random() * 100
    const duration = Math.random() * 10 + 10
    const delay = Math.random() * 5

    flake.innerHTML = "&#10052;"
    flake.style.cssText = `
      position: fixed;
      top: -20px;
      left: ${startX}%;
      font-size: ${size}px;
      color: rgba(255, 255, 255, ${Math.random() * 0.5 + 0.2});
      animation: snowfall ${duration}s linear ${delay}s infinite;
      pointer-events: none;
      z-index: 1;
    `

    this.containerTarget.appendChild(flake)
    this.snowflakes.push(flake)

    // Remove old snowflakes if too many
    if (this.snowflakes.length > 70) {
      const old = this.snowflakes.shift()
      old.remove()
    }
  }
}
