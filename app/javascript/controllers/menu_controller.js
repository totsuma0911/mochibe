import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["overlay", "menu", "button", "line1", "line2", "line3"]

  connect() {
    this.isOpen = false
  }

  toggle() {
    if (this.isOpen) {
      this.close()
    } else {
      this.open()
    }
  }

  open() {
    this.isOpen = true

    // オーバーレイを表示
    this.overlayTarget.classList.remove("opacity-0", "invisible")
    this.overlayTarget.classList.add("opacity-100", "visible")

    // メニューをスライドイン
    this.menuTarget.classList.remove("-translate-x-full")
    this.menuTarget.classList.add("translate-x-0")

    // ハンバーガー → × 変形
    this.line1Target.classList.add("rotate-45", "translate-y-2")
    this.line2Target.classList.add("opacity-0")
    this.line3Target.classList.add("-rotate-45", "-translate-y-2")

    // 背景スクロール無効
    document.body.style.overflow = "hidden"
  }

  close() {
    this.isOpen = false

    // オーバーレイを非表示
    this.overlayTarget.classList.remove("opacity-100", "visible")
    this.overlayTarget.classList.add("opacity-0", "invisible")

    // メニューをスライドアウト
    this.menuTarget.classList.remove("translate-x-0")
    this.menuTarget.classList.add("-translate-x-full")

    // × → ハンバーガー 変形
    this.line1Target.classList.remove("rotate-45", "translate-y-2")
    this.line2Target.classList.remove("opacity-0")
    this.line3Target.classList.remove("-rotate-45", "-translate-y-2")

    // 背景スクロール有効
    document.body.style.overflow = ""
  }

  stopPropagation(event) {
    event.stopPropagation()
  }

  disconnect() {
    document.body.style.overflow = ""
  }
}