import { Controller } from "@hotwired/stimulus"

// Lists the closest resorts to the visitor. Location is used only in the browser; nothing is sent to the server.
export default class extends Controller {
  static targets = ["status", "results"]
  static values = { resorts: Array }

  locate() {
    if (!navigator.geolocation) { this.statusTarget.textContent = "Your browser doesn't support location. Pick a city below."; return }
    this.statusTarget.textContent = "Finding resorts near you…"
    navigator.geolocation.getCurrentPosition(
      (pos) => this.render(pos.coords.latitude, pos.coords.longitude),
      () => { this.statusTarget.textContent = "Location wasn't shared. Pick a city below instead." },
      { timeout: 10000, maximumAge: 600000 }
    )
  }

  render(lat, lon) {
    const nearest = this.resortsValue
      .map((r) => ({ ...r, mi: this.miles(lat, lon, r.la, r.lo) }))
      .sort((a, b) => a.mi - b.mi)
      .slice(0, 12)
    this.statusTarget.textContent = `The ${nearest.length} closest resorts Snow Way tracks (straight-line miles):`
    this.resultsTarget.innerHTML = nearest.map((r) => `
      <li><a href="/resorts/${r.s}" class="flex justify-between gap-3 bg-slate-800/50 hover:bg-slate-700/50 border border-slate-700 hover:border-cyan-500 rounded-lg px-4 py-3 transition">
        <span><span class="font-semibold">${this.escape(r.n)}</span><span class="block text-xs text-slate-400">${this.escape(r.r)} · ~${r.mi} mi${r.p ? " · " + this.escape(r.p) : ""}</span></span>
        <span class="text-cyan-300 font-bold self-center">${r.t}" <span class="text-xs text-slate-400 font-normal">7-day</span></span>
      </a></li>`).join("")
  }

  miles(lat1, lon1, lat2, lon2) {
    const rad = Math.PI / 180
    const a = Math.sin(((lat2 - lat1) * rad) / 2) ** 2 + Math.cos(lat1 * rad) * Math.cos(lat2 * rad) * Math.sin(((lon2 - lon1) * rad) / 2) ** 2
    return Math.round(3958.8 * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a)))
  }

  escape(s) { return String(s).replace(/[&<>"']/g, (c) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" }[c])) }
}
