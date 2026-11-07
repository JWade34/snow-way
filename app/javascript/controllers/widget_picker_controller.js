import { Controller } from "@hotwired/stimulus"

// Builds the embed code for one resort's snow forecast widget.
export default class extends Controller {
  static targets = ["select", "preview", "code"]

  connect() { this.update() }

  update() {
    const option = this.selectTarget.selectedOptions[0]
    const slug = option.value
    const name = option.textContent.trim()
    this.previewTarget.src = `/embed/resorts/${slug}`
    this.codeTarget.value =
      `<iframe src="https://snowway.app/embed/resorts/${slug}" title="${name} snow forecast" width="100%" height="250" style="border:0;border-radius:12px;max-width:420px" loading="lazy"></iframe>\n` +
      `<p style="font-size:12px"><a href="https://snowway.app/resorts/${slug}">${name} snow forecast</a> by Snow Way</p>`
  }
}
