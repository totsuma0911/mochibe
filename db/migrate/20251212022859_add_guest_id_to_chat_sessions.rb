class AddGuestIdToChatSessions < ActiveRecord::Migration[7.2]
  def change
    add_column :chat_sessions, :guest_id, :string
    add_index :chat_sessions, :guest_id
  end
end
