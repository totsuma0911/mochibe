class Message < ApplicationRecord
  belongs_to :chat_session                     # 各メッセージは必ず1つのChatSessionに属する（関連付け）

  validates :content, presence: true              # content（本文）は必須。空だと保存できない
  validates :sender, presence: true               # senderも必須

  enum sender: { user: 0, ai: 1 }             # senderを整数で管理（0: ユーザー、1: AI/システム）

  scope :by_user, -> { where(sender: :user) }    # ユーザーのメッセージのみを取得
  scope :by_ai, -> { where(sender: :ai) }        # AIのメッセージのみを取得
  scope :recent, ->(limit = 10) { order(created_at: :desc).limit(limit) }  # 最新のメッセージを取得

  default_scope { order(created_at: :asc) }       # デフォルトで作成日時の昇順（古い→新しい）で並べる

  def user_message?
    sender == "user"
  end

  def ai_message?
    sender == "ai"
  end
end
