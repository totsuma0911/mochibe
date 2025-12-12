class MessagesController < ApplicationController
  def create
    @chat_session = ChatSession.find(params[:chat_session_id])  # どのセッションに属するメッセージか特定
    @user_message = @chat_session.messages.new(message_params)  # ユーザーのメッセージを作成

    respond_to do |format|
      if @user_message.save                                     # ユーザーメッセージ保存に成功したら
        # AI応答を生成
        @ai_message = generate_ai_response(@user_message)

        format.turbo_stream                                     # Turbo Stream用のレスポンスを返す
        format.html { redirect_to @chat_session }
      else
        format.html { redirect_to @chat_session, alert: "送信できませんでした" }
      end
    end
  end

  private

  def message_params
    params.require(:message).permit(:content, :sender, :step)
  end

  # AI応答を生成して保存
  def generate_ai_response(user_message)
    # ThreeWhyAiServiceを使用してAI応答を生成
    ai_service = ThreeWhyAiService.new(@chat_session)
    response_data = ai_service.generate_response(user_message)

    # AI応答をメッセージとして保存
    @chat_session.messages.create!(
      content: response_data[:content],
      sender: :ai,
      step: response_data[:step]
    )
  rescue StandardError => e
    # エラー時はフォールバックメッセージを返す
    Rails.logger.error("AI Response Generation Error: #{e.message}")
    @chat_session.messages.create!(
      content: "申し訳ございません。応答の生成に失敗しました。もう一度お試しください。",
      sender: :ai,
      step: 0
    )
  end
end