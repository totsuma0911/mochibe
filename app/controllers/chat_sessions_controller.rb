class ChatSessionsController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :redirect_to_home

  def show
    guest_id = cookies.permanent.signed[:guest_id]
    @chat_session = ChatSession.find(params[:id])

    # 自分のセッションか確認（セキュリティ対策）
    unless @chat_session.guest_id == guest_id
      redirect_to root_path, alert: "このセッションにはアクセスできません"
      return
    end

    @messages = @chat_session.messages
    @message = Message.new
  end

  def create
    @chat_session = ChatSession.new                                   # 新しいチャットセッション（本日の箱）を作成
    if @chat_session.save                                             # 保存できたら
      redirect_to @chat_session, notice: "本日の分析を開始しました"     # そのセッションの詳細画面に移動して、開始メッセージを表示
    else
      redirect_to chat_sessions_path, alert: "分析を開始できませんでした" # 保存に失敗したら一覧へ戻して、エラーメッセージを表示
    end
  end

  # 新規分析セッションを開始（常に新しいセッションを作成）
  def new_session
    guest_id = cookies.permanent.signed[:guest_id] ||= SecureRandom.uuid
    @chat_session = ChatSession.create!(guest_id: guest_id)
    redirect_to chat_session_path(@chat_session)
  end

  private

  def redirect_to_home
    redirect_to root_path, alert: "セッションが見つかりませんでした。新しい分析を始めてください。"
  end
end
