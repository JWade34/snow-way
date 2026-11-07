import { Controller } from "@hotwired/stimulus"

// Interactive packing checklist. Progress is a per-device convenience kept in localStorage.
const KEY = "snowway:packing"

export default class extends Controller {
  static targets = ["count", "total", "bar", "kids", "kidsToggle"]

  connect() {
    const saved = this.read()
    if (saved.kids !== undefined) this.kidsToggleTarget.checked = saved.kids
    this.boxes.forEach(b => { b.checked = (saved.items || []).includes(b.value) })
    this.applyKids()
  }

  get boxes() { return Array.from(this.element.querySelectorAll('input[type=checkbox][value]')) }
  get visible() { return this.boxes.filter(b => !b.closest('[hidden]')) }

  toggleKids() { this.applyKids(); this.save() }

  applyKids() {
    this.kidsTarget.hidden = !this.kidsToggleTarget.checked
    this.update()
  }

  save() {
    this.write({ kids: this.kidsToggleTarget.checked, items: this.boxes.filter(b => b.checked).map(b => b.value) })
    this.update()
  }

  update() {
    const visible = this.visible
    const done = visible.filter(b => b.checked).length
    this.countTarget.textContent = done
    this.totalTarget.textContent = visible.length
    this.barTarget.style.width = `${visible.length ? Math.round(done * 100 / visible.length) : 0}%`
  }

  reset() { this.boxes.forEach(b => { b.checked = false }); this.save() }
  print() { window.print() }

  read() { try { return JSON.parse(localStorage.getItem(KEY)) || {} } catch { return {} } }
  write(data) { try { localStorage.setItem(KEY, JSON.stringify(data)) } catch {} }
}
