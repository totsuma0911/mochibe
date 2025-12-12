class ChatSession < ApplicationRecord
    has_many :messages, dependent: :destroy # 複数のメッセージを持つ（セッション削除時にまとめて削除）
    has_one :analysis, dependent: :destroy # 分析結果を1つ持つ（セッション削除時に削除）
end
