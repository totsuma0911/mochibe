import { Controller } from "@hotwired/stimulus"

export default class extends Controller { // Stimulusコントローラ: フォームでEnterキーを押したときの挙動を制御
  submitOnEnter(event) {
    // モバイルデバイス判定（768px以下 = Tailwindのmd breakpoint未満）
    const isMobile = window.matchMedia("(max-width: 768px)").matches

    // モバイル: Enterで改行（送信ボタンのみで送信）
    // PC: Enterで送信、Shift+Enterで改行
    if (event.key === "Enter" && !event.shiftKey && !isMobile) {
      event.preventDefault()          // textareaの改行をキャンセル
      this.element.requestSubmit()    // このフォームを送信
      this.element.reset()            // 送信後にフォームをクリア
    }
  }
}