module MessagesHelper
  # ウェルカムメッセージ（step 0）用のアニメーションクラスを返す
  def animation_class_for_welcome(message)
    # step 0以外、またはAI以外のメッセージはアニメーション不要
    return "" unless message.step == 0 && message.sender == "ai"

    # step 0のメッセージを作成順に取得
    step_0_messages = message.chat_session.messages.where(step: 0, sender: :ai).order(:created_at)
    index = step_0_messages.index(message)

    # メッセージの順序に応じてアニメーションクラスを返す
    case index
    when 0
      "animate-fade-up-slow"
    when 1
      "animate-fade-up-slow anim-delay-1200"
    when 2
      "animate-fade-up-slow anim-delay-2400"
    else
      ""
    end
  rescue StandardError => e
    # エラーが起きてもアニメーションなしで表示
    Rails.logger.error("Animation class error: #{e.message}")
    ""
  end
end
