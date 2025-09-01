class CreateMessages < ActiveRecord::Migration[7.2]
  def change
    create_table :messages do |t|
      t.text :content                                   # メッセージ本文（文字数制限はモデルで制御）
      t.integer :sender, default: 0                     # 送信者（0: ユーザー, 1: システム/AI）デフォルトはユーザー
      t.references :chat_session, null: false,          # 関連するチャットセッションの外部キー
                   foreign_key: true                    # chat_sessions.id に必ず紐づける（参照整合性を保証）
      t.integer :step                                   # 深掘り質問の段階（1〜3想定）
      t.timestamps                                      # 作成日時(created_at)と更新日時(updated_at)
    end
  end
end