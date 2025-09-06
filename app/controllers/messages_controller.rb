class MessagesController < ApplicationController
  def create
    @chat_session = ChatSession.find(params[:chat_session_id])  # どのセッションに属するメッセージか特定
    @message = @chat_session.messages.new(message_params)       # 新しいMessageを作成（本文やsenderなどを受け取る）

    respond_to do |format|                                      # リクエスト形式に応じてレスポンスを返す
      if @message.save                                          # メッセージ保存に成功したら
        format.turbo_stream                                     # Turbo Stream用のレスポンスを返す
        format.html { redirect_to @chat_session }               # HTMLリクエストならセッション画面にリダイレクト
      else
        format.html { redirect_to @chat_session, alert: "送信できませんでした" } # 保存失敗時はフォーム再表示 layouts/application.html.erb に flash 表示処理追加
      end
    end
  end

  private

  def message_params
    params.require(:message).permit(:content, :sender, :step)   # Strong Parameters（許可するカラムを限定）
  end
end