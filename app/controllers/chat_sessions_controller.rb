class ChatSessionsController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :redirect_to_home

  def show
    @chat_session = ChatSession.find(params[:id])

    # 自分のセッションか確認（セキュリティ対策：ログインユーザーまたはゲスト）
    unless owns_session?(@chat_session)
      redirect_to root_path, alert: "このセッションにはアクセスできません"
      return
    end

    @messages = @chat_session.messages
    @message = Message.new
  end

  def create
    # ログインユーザーならuser_id、ゲストならguest_idでセッション作成
    @chat_session = if user_signed_in?
                      ChatSession.new(user_id: current_user.id)
                    else
                      ChatSession.new(guest_id: guest_id)
                    end

    if @chat_session.save
      redirect_to @chat_session, notice: "本日の分析を開始しました"
    else
      redirect_to root_path, alert: "分析を開始できませんでした"
    end
  end

  # 新規分析セッションを開始（常に新しいセッションを作成）
  def new_session
    @chat_session = if user_signed_in?
                      ChatSession.create!(user_id: current_user.id)
                    else
                      ChatSession.create!(guest_id: guest_id)
                    end
    redirect_to chat_session_path(@chat_session)
  end

  private

  def redirect_to_home
    redirect_to root_path, alert: "セッションが見つかりませんでした。新しい分析を始めてください。"
  end
end
