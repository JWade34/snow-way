import { Controller } from "@hotwired/stimulus"

// Filters a long list as you type. Items carry data-filter-text; groups hide when empty.
export default class extends Controller {
  static targets = ["input", "item", "group"]

  filter() {
    const q = this.inputTarget.value.trim().toLowerCase()
    this.itemTargets.forEach((el) => { el.hidden = q && !el.dataset.filterText.includes(q) })
    this.groupTargets.forEach((g) => {
      g.hidden = !g.querySelector("[data-filter-target='item']:not([hidden])")
    })
  }
}
