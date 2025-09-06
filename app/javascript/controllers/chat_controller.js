import { Controller } from "@hotwired/stimulus" 

/**
 * チャットの「外枠」をスクロールさせるコントローラ
 * - 追加されたメッセージに追従して常に一番下へスクロール
 * - Turbo Stream の append はターゲット再接続を起こさないため、
 *   MutationObserver で #messages の子要素追加を監視する
 */
export default class extends Controller {
  static targets = ["messages"]

  connect() {
    console.log("✅ ChatController connected")
    // 初期表示時に最下部へ
    this.scrollToBottom()

    // メッセージの子要素追加を監視して、そのたびにスクロール
    this._observer = new MutationObserver((mutations) => {
      for (const m of mutations) {
        if (m.type === "childList" && m.addedNodes && m.addedNodes.length > 0) {
          this.scrollToBottom()
          break
        }
      }
    })
    if (this.hasMessagesTarget) {
      this._observer.observe(this.messagesTarget, { childList: true, subtree: false })
    } else {
      console.warn("⚠️ data-chat-target=\"messages\" が見つかりません")
    }

    // フォーム置換などの直後にも一応スクロール（保険）
    this._onTurboSubmitEnd = () => this.scrollToBottom()
    document.addEventListener("turbo:submit-end", this._onTurboSubmitEnd)
  }

  disconnect() {
    if (this._observer) {
      this._observer.disconnect()
      this._observer = null
    }
    if (this._onTurboSubmitEnd) {
      document.removeEventListener("turbo:submit-end", this._onTurboSubmitEnd)
      this._onTurboSubmitEnd = null
    }
  }

  /**
   * 実際にスクロールさせる処理
   * - スクロールさせるのは「外枠」（= data-controller="chat" が付いた要素）
   * - requestAnimationFrame で描画反映後に実行してズレを防ぐ
   */
  scrollToBottom() {
    const box = this.element
    if (!box) return
    // 外枠は h-96 / overflow-y-scroll などでスクロール可能にしておくこと
    requestAnimationFrame(() => {
      try {
        box.scrollTop = box.scrollHeight
        // デバッグしたい時は下のログを有効化
        // console.log("👉 scrollToBottom", { scrollTop: box.scrollTop, scrollHeight: box.scrollHeight })
      } catch (e) {
        console.warn("scrollToBottom でエラー:", e)
      }
    })
  }
}