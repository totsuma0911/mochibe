import { Controller } from "@hotwired/stimulus"

/**
 * モーダル制御用のStimulusコントローラー
 * - 初回訪問時にアイコンを強調表示
 * - モーダルの開閉
 * - 「次回から表示しない」機能
 */
export default class extends Controller {
  static targets = ["dialog", "button", "badge", "dontShowAgain"]

  connect() {
    // 初回訪問かチェックして、必要なら強調表示
    this.checkFirstVisit()
  }

  /**
   * 初回訪問かどうかをチェック
   * localStorageで管理（modal_visited: true/false）
   */
  checkFirstVisit() {
    const hasVisited = localStorage.getItem('modal_visited')
    const dontShow = localStorage.getItem('modal_dont_show')

    // 訪問済みでない、かつ「次回から表示しない」が設定されていない場合
    if (!hasVisited && !dontShow) {
      // 強調表示（パルスアニメーション）を追加
      this.buttonTarget.classList.add('first-visit')

      // バッジを表示
      if (this.hasBadgeTarget) {
        this.badgeTarget.classList.remove('hidden')
      }
    }
  }

  /**
   * モーダルを開く
   */
  open() {
    this.dialogTarget.showModal()

    // モーダルを開いたら「訪問済み」として記録
    this.markAsVisited()
  }

  /**
   * モーダルを閉じる
   * - 「次回から表示しない」がチェックされていたらlocalStorageに保存
   */
  close() {
    // 「次回から表示しない」がチェックされている場合
    if (this.hasDontShowAgainTarget && this.dontShowAgainTarget.checked) {
      localStorage.setItem('modal_dont_show', 'true')
    }

    this.dialogTarget.close()
  }

  /**
   * 訪問済みとしてマーク
   * - 強調表示を解除
   * - バッジを非表示
   */
  markAsVisited() {
    localStorage.setItem('modal_visited', 'true')

    // 強調表示を解除
    this.buttonTarget.classList.remove('first-visit')

    // バッジを非表示
    if (this.hasBadgeTarget) {
      this.badgeTarget.classList.add('hidden')
    }
  }

  /**
   * 背景クリックでモーダルを閉じる
   */
  clickOutside(event) {
    if (event.target === this.dialogTarget) {
      this.close()
    }
  }
}
