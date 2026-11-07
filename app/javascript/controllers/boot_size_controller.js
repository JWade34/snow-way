import { Controller } from "@hotwired/stimulus"

// Mirrors SizeChart.mondo_rows in app/models/size_chart.rb.
export default class extends Controller {
  static targets = ["mode", "value", "gender", "result", "detail"]

  connect() { this.calculate() }

  calculate() {
    const value = parseFloat(this.valueTarget.value)
    if (!value) { this.resultTarget.textContent = "Enter a size"; this.detailTarget.textContent = ""; return }

    const womens = this.genderTarget.value === "womens"
    let mondo = this.modeTarget.value === "cm" ? value : value + (womens ? 17 : 18)
    mondo = Math.round(mondo * 2) / 2
    if (mondo < 15 || mondo > 34) { this.resultTarget.textContent = "Check the number"; this.detailTarget.textContent = ""; return }

    const shell = Math.floor(mondo)
    this.resultTarget.textContent = `Mondo ${mondo.toFixed(1)}`
    this.detailTarget.textContent = `Try ${shell}.0/${shell}.5 shells (same shell, different liner). US men's ${mondo - 18}, US women's ${mondo - 17}.`
  }
}
