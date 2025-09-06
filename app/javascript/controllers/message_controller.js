import { Controller } from "@hotwired/stimulus"

export default class extends Controller { // Stimulusコントローラ: フォームでEnterキーを押したときの挙動を制御
  submitOnEnter(event) {
    if (event.key === "Enter" && !event.shiftKey) { // Enter が押され、Shift が押されていない場合のみ送信
      event.preventDefault()          // textareaの改行をキャンセル
      this.element.requestSubmit()    // このフォームを送信
      this.element.reset()            // 送信後にフォームをクリア
    }
  }
}