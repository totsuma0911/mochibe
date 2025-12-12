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

    # Step 4（最終分析）の場合、Analysisレコードを作成
    if response_data[:step] == 4
      # AI応答全文からAnalysisレコードを作成
      create_analysis_from_response(response_data[:content])

      # チャット画面には簡潔なメッセージとボタンだけを表示
      response_data[:content] = "お疲れさまでした！3WHY分析が完了しました。\n\n<a href='#{chat_session_analysis_path(@chat_session)}' class='inline-block mt-4 px-6 py-3 rounded-full bg-gradient-to-r from-yellow-400 to-orange-500 hover:from-yellow-500 hover:to-orange-600 text-white font-bold transition-all duration-200 transform hover:scale-105 hover:shadow-lg'>👉 分析結果を見る</a>"
    end

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

  # AI応答から構造化データを抽出してAnalysisレコードを作成
  def create_analysis_from_response(content)
    parsed_data = parse_structured_analysis(content)

    @chat_session.create_analysis!(
      root_cause: parsed_data[:root_cause],
      insights: parsed_data[:insights],
      summary: parsed_data[:summary],
      actions: parsed_data[:actions]
    )
  rescue StandardError => e
    Rails.logger.error("Analysis Creation Error: #{e.message}")
  end

  # 構造化されたAI応答をパース
  def parse_structured_analysis(content)
    {
      root_cause: extract_section(content, '【根本原因】', '【気づき】'),
      insights: extract_section(content, '【気づき】', '【まとめ】'),
      summary: extract_section(content, '【まとめ】', '【アクション】'),
      actions: extract_section(content, '【アクション】', 'ーーー')
    }
  end

  # マーカー間のテキストを抽出
  def extract_section(content, start_marker, end_marker)
    return '' unless content.include?(start_marker)

    start_pos = content.index(start_marker) + start_marker.length
    end_pos = content.index(end_marker, start_pos)

    if end_pos
      content[start_pos...end_pos].strip
    else
      content[start_pos..-1].strip
    end
  end
end