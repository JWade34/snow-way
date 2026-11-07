import { Controller } from "@hotwired/stimulus"

// Jumps straight to a resort page from the homepage search (datalist of every resort).
export default class extends Controller {
  static targets = ["input"]

  go(event) {
    const query = this.inputTarget.value.trim().toLowerCase()
    if (!query) { if (event.type === "submit") event.preventDefault(); return }
    const options = Array.from(document.querySelectorAll("#resort-options option"))
    const exact = options.find(o => o.value.toLowerCase() === query)
    // Picking from the list fires "change" with the exact name; a partial name only jumps on submit (Go/Enter).
    const match = exact || (event.type === "submit" &&
      (options.find(o => o.value.toLowerCase().startsWith(query)) || options.find(o => o.value.toLowerCase().includes(query))))
    if (match) {
      event.preventDefault()
      window.location.href = `/resorts/${match.dataset.slug}`
    }
  }
}
