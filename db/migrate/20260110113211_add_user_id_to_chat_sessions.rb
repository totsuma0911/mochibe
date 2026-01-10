class AddUserIdToChatSessions < ActiveRecord::Migration[7.2]
  def change
    add_reference :chat_sessions, :user, null: true, foreign_key: true  # null: false → null: true
  end
end