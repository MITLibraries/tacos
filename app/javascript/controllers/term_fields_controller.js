import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["template", "container"]

  add() {
    const content = this.templateTarget.content.cloneNode(true)
    this.containerTarget.appendChild(content)
  }
}
