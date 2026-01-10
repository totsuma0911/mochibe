class ChangeUserIdNullableInChatSessions < ActiveRecord::Migration[7.2]
  def change
    change_column_null :chat_sessions, :user_id, true
  end
end
