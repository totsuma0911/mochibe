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
    // 初期表示時の背景設定
    this.updateBackground()

    // ウェルカムメッセージ（step 0）がある場合は段階的にスクロール
    if (this.hasWelcomeMessages()) {
      this.scheduleWelcomeScrolls()
    } else {
      // 通常は即座にスクロール
      this.scrollToBottom()
    }

    // メッセージの子要素追加を監視して、そのたびにスクロール & 背景更新
    this._observer = new MutationObserver((mutations) => {
      for (const m of mutations) {
        if (m.type === "childList" && m.addedNodes && m.addedNodes.length > 0) {
          this.scrollToBottom()
          this.updateBackground()
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

  /**
   * ウェルカムメッセージ（step 0のAIメッセージ）が存在するかチェック
   */
  hasWelcomeMessages() {
    if (!this.hasMessagesTarget) return false

    const messages = this.messagesTarget.querySelectorAll('[data-message-step="0"]')
    return messages.length > 0
  }

  /**
   * ウェルカムメッセージのアニメーション完了に合わせて段階的にスクロール
   * - 1つ目: 2.4秒後（0s + 2.4s）
   * - 2つ目: 3.6秒後（1.2s + 2.4s）
   * - 3つ目: 4.8秒後（2.4s + 2.4s）
   */
  scheduleWelcomeScrolls() {
    // 1つ目のメッセージ完了時にスクロール
    setTimeout(() => this.scrollToBottom(), 2400)

    // 2つ目のメッセージ完了時にスクロール
    setTimeout(() => this.scrollToBottom(), 3600)

    // 3つ目のメッセージ完了時にスクロール
    setTimeout(() => this.scrollToBottom(), 4800)
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

  /**
   * 背景を更新する処理（曇り空 → 快晴）
   * - メッセージの最新stepに応じて背景グラデーションを変更
   */
  updateBackground() {
    if (!this.hasMessagesTarget) return

    // 全メッセージから最新のstepを取得
    const messages = this.messagesTarget.querySelectorAll('[data-message-step]')
    let currentStep = 0

    if (messages.length > 0) {
      const lastMessage = messages[messages.length - 1]
      currentStep = parseInt(lastMessage.dataset.messageStep || 0)
    }

    this.setBackgroundForStep(currentStep)
  }

  /**
   * stepに応じた背景クラスを設定
   */
  setBackgroundForStep(step) {
    const bgClasses = {
      0: ['bg-gradient-to-b', 'from-gray-300', 'via-gray-200', 'to-gray-100'],     // 曇り空
      1: ['bg-gradient-to-b', 'from-gray-200', 'via-blue-100', 'to-white'],        // 少し晴れ
      2: ['bg-gradient-to-b', 'from-blue-100', 'via-sky-100', 'to-white'],         // 晴れてきた
      3: ['bg-gradient-to-b', 'from-sky-200', 'via-sky-100', 'to-white'],          // もうすぐ快晴
      4: ['bg-gradient-to-b', 'from-sky-400', 'via-sky-200', 'to-white']           // 快晴！
    }

    // 全ての背景クラスを削除
    const allBgClasses = [
      'bg-gradient-to-b',
      'from-gray-300', 'from-gray-200', 'from-blue-100', 'from-sky-200', 'from-sky-400',
      'via-gray-200', 'via-blue-100', 'via-sky-100', 'via-sky-200',
      'to-gray-100', 'to-white'
    ]
    this.element.classList.remove(...allBgClasses)

    // 新しい背景クラスを追加
    const newClasses = bgClasses[step] || bgClasses[0]
    this.element.classList.add(...newClasses)
  }
}