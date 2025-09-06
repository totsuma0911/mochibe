class ChatSession < ApplicationRecord
    has_many :messages, dependent: :destroy # 複数のメッセージを持つ（セッション削除時にまとめて削除）
end
