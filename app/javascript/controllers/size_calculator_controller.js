import { Controller } from "@hotwired/stimulus"

// Mirrors SizeChart in app/models/size_chart.rb.
const SKI_ABILITY = { beginner: -15, intermediate: -8, advanced: -2, expert: 4 }
const SKI_STYLE = { groomers: -3, "all-mountain": 0, powder: 5, park: -5 }
const BOARD_STYLE = { park: -4, "all-mountain": 0, powder: 4 }
const BOARD_ABILITY = { beginner: -2, intermediate: 0, advanced: 1 }

export default class extends Controller {
  static targets = ["feet", "inches", "weight", "ability", "style", "boot", "bootGender", "result", "detail"]
  static values = { kind: String }

  connect() { this.calculate() }

  calculate() {
    const heightCm = Math.round(((parseInt(this.feetTarget.value) || 0) * 12 + (parseInt(this.inchesTarget.value) || 0)) * 2.54)
    const weight = parseFloat(this.weightTarget.value) || null
    if (heightCm < 90) { this.resultTarget.textContent = "Enter your height"; return }

    const adjust = this.weightAdjust(heightCm, weight)
    const ability = this.abilityTarget.value
    const style = this.styleTarget.value

    if (this.kindValue === "ski") {
      const center = heightCm + SKI_ABILITY[ability] + SKI_STYLE[style] + adjust
      const pole = Math.round((heightCm * 0.68) / 5) * 5
      this.resultTarget.textContent = `${center - 3}–${center + 3} cm skis`
      this.detailTarget.textContent = `Poles: about ${pole} cm. Height ${heightCm} cm.`
    } else {
      const center = Math.round(heightCm * 0.87) + BOARD_STYLE[style] + BOARD_ABILITY[ability] + adjust
      let boot = parseFloat(this.bootTarget.value) || 0
      if (this.bootGenderTarget.value === "womens" && boot) boot -= 1.5
      const width = boot >= 11 ? "Wide (W) board" : boot >= 10 ? "Regular or mid-wide board" : "Regular width"
      this.resultTarget.textContent = `${center - 4}–${center + 4} cm board`
      this.detailTarget.textContent = boot ? `${width} for your boot size. Height ${heightCm} cm.` : `Height ${heightCm} cm. Add your boot size for width.`
    }
  }

  weightAdjust(heightCm, weightLb) {
    if (!weightLb) return 0
    const bmi = (weightLb * 0.4536) / Math.pow(heightCm / 100, 2)
    return bmi > 27 ? 3 : bmi < 19 ? -3 : 0
  }
}
