class CreateChatSessions < ActiveRecord::Migration[7.2]
  def change
    create_table :chat_sessions do |t|
      t.timestamps # 作成日時(created_at)と更新日時(updated_at)
    end
  end
end
