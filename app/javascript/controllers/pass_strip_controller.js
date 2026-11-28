import { Controller } from "@hotwired/stimulus"

const LABELS = { epic: "Epic", ikon: "Ikon", indy: "Indy", mountain_collective: "Mountain Collective" }

// iPhone app home: asks once for the visitor's pass, then shows the 3 snowiest resorts on it.
export default class extends Controller {
  static targets = ["ask", "list", "title", "items"]

  connect() {
    if (!window.Capacitor?.isNativePlatform?.()) return
    this.element.classList.remove("hidden")
    this.render(localStorage.getItem("snowway_pass"))
  }

  pick(event) {
    const pass = event.currentTarget.dataset.pass
    localStorage.setItem("snowway_pass", pass)
    window.snowwayApp?.native?.("setPass", { pass })
    window.posthog?.capture?.("pass_picked", { pass, placement: "home" })
    this.render(pass)
  }

  async render(pass) {
    if (!pass) { this.askTarget.classList.remove("hidden"); this.listTarget.classList.add("hidden"); return }
    this.askTarget.classList.add("hidden")
    if (!LABELS[pass]) { this.element.classList.add("hidden"); return } // no pass: the main ranking already covers it
    const data = await fetch(`/api/app/powder?limit=3&pass=${pass}`).then((r) => r.json()).catch(() => null)
    if (!data?.resorts?.length) return
    this.titleTarget.textContent = `Powder on your ${LABELS[pass]} pass`
    this.itemsTarget.replaceChildren(...data.resorts.map((r) => {
      const li = document.createElement("li")
      const a = document.createElement("a")
      a.href = `/resorts/${r.slug}`
      a.className = "flex justify-between gap-3 py-2 no-underline text-white"
      const name = document.createElement("span"); name.className = "font-semibold"; name.textContent = r.name
      const inches = document.createElement("span"); inches.className = "text-cyan-300 font-bold"; inches.textContent = `${r.next_7_days_in}"`
      a.append(name, inches); li.append(a); return li
    }))
    this.listTarget.classList.remove("hidden")
  }
}
