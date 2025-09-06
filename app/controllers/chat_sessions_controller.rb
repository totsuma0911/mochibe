class ChatSessionsController < ApplicationController
  def show
    @chat_session = ChatSession.find(params[:id])   # URLのidから、その日のチャットセッションを特定
    @messages = @chat_session.messages              # そのセッションに紐づいている全メッセージを取得
    @message = Message.new                          # 入力フォーム用の空メッセージを準備
  end

  def create
    @chat_session = ChatSession.new                                   # 新しいチャットセッション（本日の箱）を作成
    if @chat_session.save                                             # 保存できたら
      redirect_to @chat_session, notice: "本日の分析を開始しました"     # そのセッションの詳細画面に移動して、開始メッセージを表示
    else
      redirect_to chat_sessions_path, alert: "分析を開始できませんでした" # 保存に失敗したら一覧へ戻して、エラーメッセージを表示
    end
  end
  
end
