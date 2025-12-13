class HomeController < ApplicationController
  def index
    guest_id = cookies.permanent[:guest_id] ||= SecureRandom.uuid

    # 最新のセッションを取得
    last_session = ChatSession.where(guest_id: guest_id).last

    # セッションが存在し、かつ分析が完了している（step 4まで到達）場合は新しいセッションを作成
    if last_session && last_session.messages.exists?(step: 4)
      @chat_session = ChatSession.create!(guest_id: guest_id)
    else
      # 既存のセッションを継続、または新規作成
      @chat_session = last_session || ChatSession.create!(guest_id: guest_id)
    end
  end

  def how_to_use
    # 使い方ガイドページを表示
  end
end
