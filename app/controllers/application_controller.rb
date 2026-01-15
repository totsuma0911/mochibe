class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  private

  # セッションの所有者かどうかを確認（ログインユーザーまたはゲスト）
  def owns_session?(chat_session)
    if user_signed_in?
      chat_session.user_id == current_user.id
    else
      chat_session.guest_id == guest_id
    end
  end

  # ゲストIDを取得（なければ生成）
  def guest_id
    cookies.permanent.signed[:guest_id] ||= SecureRandom.uuid
  end

  # 現在のユーザーまたはゲストのセッションを取得
  def current_sessions
    if user_signed_in?
      ChatSession.where(user_id: current_user.id)
    else
      ChatSession.where(guest_id: guest_id)
    end
  end
end
