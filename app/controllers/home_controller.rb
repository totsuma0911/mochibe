class HomeController < ApplicationController
  def index
    if user_signed_in?
      # ログイン済みユーザー
      @chat_session = find_or_create_session_for_user(current_user)
    else
      # ゲストユーザー
      guest_id = cookies.permanent.signed[:guest_id] ||= SecureRandom.uuid
      @chat_session = find_or_create_session_for_guest(guest_id)
    end
  end

  def how_to_use
    # 使い方ガイドページを表示
  end

  private

  def find_or_create_session_for_user(user)
    last_session = user.chat_sessions.last

    if last_session && last_session.messages.exists?(step: 4)
      ChatSession.create!(user_id: user.id)
    else
      last_session || ChatSession.create!(user_id: user.id)
    end
  end

  def find_or_create_session_for_guest(guest_id)
    last_session = ChatSession.where(guest_id: guest_id).last

    if last_session && last_session.messages.exists?(step: 4)
      ChatSession.create!(guest_id: guest_id)
    else
      last_session || ChatSession.create!(guest_id: guest_id)
    end
  end

end
