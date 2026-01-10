class ChatSession < ApplicationRecord
    has_many :messages, dependent: :destroy # 複数のメッセージを持つ（セッション削除時にまとめて削除）
    has_one :analysis, dependent: :destroy # 分析結果を1つ持つ（セッション削除時に削除）
    belongs_to :user, optional: true #ゲストIDとユーザーIDの両方をサポート
    after_create_commit :create_welcome_message  # セッション作成時に自動でウェルカムメッセージを作成

    private

    def create_welcome_message
      # 念のため、既にメッセージがある場合はスキップ
      return if messages.exists?

      # ウェルカムメッセージを3つに分けて作成
      messages.create!(
        content: "一日の始まりや、気分がすぐれないとき、\nそして一日の振り返りに、\n気持ちを整理するためのチャットです ☀️🌙",
        sender: :ai,
        step: 0
      )

      messages.create!(
        content: "これから質問を重ねながら、\n今の気持ちを一緒に整理していきます。\n3つの質問にお答えいただくと、\n分析結果が表示されます 🔍",
        sender: :ai,
        step: 0
      )

      messages.create!(
        content: "今感じていることを、\n思いつくまま書いてみてください ✍️",
        sender: :ai,
        step: 0
      )
    rescue StandardError => e
      # 万が一エラーが起きてもログに残すだけ（セッション作成は成功させる）
      Rails.logger.error("Welcome message creation failed: #{e.message}")
    end
end
