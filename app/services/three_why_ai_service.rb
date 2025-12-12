class ThreeWhyAiService
  # OpenAI APIを使用して3WHY分析を行うサービスクラス

  def initialize(chat_session)
    @chat_session = chat_session
    @client = OpenAI::Client.new(access_token: ENV.fetch('OPENAI_API_KEY'))
  end

  # ユーザーメッセージに対するAI応答を生成
  def generate_response(user_message)
    current_step = calculate_current_step

    if current_step < 3
      # Step 1-3: 深掘り質問を生成
      generate_why_question(current_step, user_message)
    else
      # Step 4: 最終的な分析結果を生成
      generate_final_analysis
    end
  rescue Faraday::Error, OpenAI::Error => e
    # API接続エラー時のフォールバック
    Rails.logger.error("OpenAI API Error: #{e.message}")
    handle_api_error(e)
  end

  private

  # 現在のstepを計算（最後のAIメッセージのstep + 1）
  def calculate_current_step
    last_ai_message = @chat_session.messages.by_ai.last
    last_ai_message&.step || 0
  end

  # 深掘り質問を生成（Step 1-3）
  def generate_why_question(step, user_message)
    response = @client.chat(
      parameters: {
        model: ENV.fetch('OPENAI_MODEL', 'gpt-4o-mini'),
        messages: build_messages_for_question(step),
        temperature: 0.7,
        max_tokens: 300
      }
    )

    {
      content: response.dig('choices', 0, 'message', 'content'),
      step: step + 1
    }
  end

  # 最終分析結果を生成（Step 4）
  def generate_final_analysis
    messages_for_api = build_messages_for_analysis

    response = @client.chat(
      parameters: {
        model: ENV.fetch('OPENAI_MODEL', 'gpt-4o-mini'),
        messages: messages_for_api,
        temperature: 0.8,
        max_tokens: 800
      }
    )

    content = response.dig('choices', 0, 'message', 'content')

    {
      content: content,
      step: 4
    }
  end

  # 質問生成用のメッセージ履歴を構築
  def build_messages_for_question(step)
    [
      { role: 'system', content: system_prompt_for_question(step) },
      *conversation_history,
    ]
  end

  # 分析生成用のメッセージ履歴を構築
  def build_messages_for_analysis
    [
      { role: 'system', content: system_prompt_for_analysis },
      *conversation_history
    ]
  end

  # 会話履歴をOpenAI API形式に変換
  def conversation_history
    @chat_session.messages.order(:created_at).map do |message|
      {
        role: message.sender == 'user' ? 'user' : 'assistant',
        content: message.content
      }
    end
  end

  # Step別の質問生成用システムプロンプト
  def system_prompt_for_question(step)
    base_prompt = <<~PROMPT
      あなたは3WHY分析の専門家です。ユーザーの悩みの本質的な根本原因を見つけ出すことが使命です。

      【重要な心構え】
      - 優しく寄り添いながらも、核心を突く鋭い質問をしてください
      - 表面的な慰めではなく、本当の原因に気づけるよう導いてください
      - ユーザーが目を背けている問題にも、優しく光を当ててください

      【質問のポイント】
      - 抽象的な回答には具体性を求める
      - 他責的な回答には自分の関わりを問う
      - 表面的な理由には「本当にそれだけ？」と掘り下げる
      - 一般論ではなく、その人自身の体験や感情を引き出す
    PROMPT

    step_instruction = case step
    when 0
      "これは最初の質問です。ユーザーの悩みに共感を示しつつ、「それはどうしてだと思いますか？」という形で、最初の「なぜ？」を優しく問いかけてください。短く、親しみやすく。"
    when 1
      "これは2回目の深掘りです。ユーザーの答えを受け止めた上で、「その理由の、さらに奥にある本当の原因は何だと思いますか？」という形で、より深い「なぜ？」を問いかけてください。本質に迫る質問を。"
    when 2
      "これは3回目の、最後の深掘りです。「もし正直に答えるなら、その背景には何があると思いますか？」という形で、最も本質的な「なぜ？」を問いかけてください。核心を突く、でも優しく。"
    end

    "#{base_prompt}\n#{step_instruction}"
  end

  # 最終分析用システムプロンプト
  def system_prompt_for_analysis
    <<~PROMPT
      あなたは3WHY分析の専門家です。ユーザーとの3回の深掘り対話は既に完了しました。

      **【絶対に守ること】**
      - これ以上質問をしてはいけません
      - 対話は完了しています
      - 今は分析結果のみを返してください

      これまでの対話を振り返り、必ず以下の形式で分析結果を提示してください：

      【根本原因】
      あなたの悩みの根っこには「○○」があるようです。
      （ユーザー自身が気づいていなかった本質的な原因を、優しく、でもはっきりと伝える）

      【気づき】
      • （対話から見えてきた重要な気づき1）
      • （対話から見えてきた重要な気づき2）
      • （対話から見えてきた重要な気づき3）

      【まとめ】
      今回の対話を通じて分かったこと。
      （全体を振り返り、今後に向けたメッセージ）

      【アクション】
      • （具体的で実践可能なアクション1）
      • （具体的で実践可能なアクション2）

      ーーー
      お疲れさまでした。今日も自分と向き合う時間を作れたこと、素晴らしいです。

      **【最重要】**
      - 絶対に質問をしないでください
      - 必ず上記の形式（【根本原因】【気づき】【まとめ】【アクション】）で始めてください
      - 表面的な励ましではなく、本質的な洞察を提供してください
      - 具体的で、明日から実践できるアクションを提案してください
    PROMPT
  end

  # API エラーハンドリング
  def handle_api_error(error)
    error_message = if error.is_a?(Faraday::UnauthorizedError)
      "申し訳ございません。API認証に失敗しました。設定を確認してください。"
    elsif error.is_a?(Faraday::TimeoutError)
      "申し訳ございません。応答に時間がかかっています。もう一度お試しください。"
    else
      "申し訳ございません。一時的なエラーが発生しました。もう一度送信してください。"
    end

    {
      content: error_message,
      step: calculate_current_step
    }
  end
end
