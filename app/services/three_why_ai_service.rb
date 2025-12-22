class ThreeWhyAiService
  # OpenAI APIを使用して3WHY分析を行うサービスクラス

  def initialize(chat_session)
    @chat_session = chat_session
    @client = OpenAI::Client.new(access_token: ENV.fetch("OPENAI_API_KEY"))
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
        model: ENV.fetch("OPENAI_MODEL", "gpt-4o-mini"),
        messages: build_messages_for_question(step),
        temperature: 0.7,
        max_tokens: 300
      }
    )

    {
      content: response.dig("choices", 0, "message", "content"),
      step: step + 1
    }
  end

  # 最終分析結果を生成（Step 4）
  def generate_final_analysis
    messages_for_api = build_messages_for_analysis

    response = @client.chat(
      parameters: {
        model: ENV.fetch("OPENAI_MODEL", "gpt-4o-mini"),
        messages: messages_for_api,
        temperature: 0.7,
        max_tokens: 1500
      }
    )

    content = response.dig("choices", 0, "message", "content")

    {
      content: content,
      step: 4
    }
  end

  # 質問生成用のメッセージ履歴を構築
  def build_messages_for_question(step)
    [
      { role: "system", content: system_prompt_for_question(step) },
      *conversation_history
    ]
  end

  # 分析生成用のメッセージ履歴を構築
  def build_messages_for_analysis
    [
      { role: "system", content: system_prompt_for_analysis },
      *conversation_history
    ]
  end

  # 会話履歴をOpenAI API形式に変換
  def conversation_history
    @chat_session.messages.order(:created_at).map do |message|
      {
        role: message.sender == "user" ? "user" : "assistant",
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
      あなたは3WHY分析とセルフコーチングの専門家です。ユーザーとの3回の深掘り対話は完了しました。

      **【このツールの本質】**
      - これはセルフコーチングツールです
      - 依存を生む過度な共感ではなく、自分で考え、自分で解決する力を引き出すことが目的
      - 答えを与えるのではなく、気づきと方向性を示し、ユーザー自身の行動を促す

      **【絶対に守ること】**
      - これ以上質問をしてはいけません
      - 対話は完了しています
      - 必ず以下の形式で、指定された比率とトーンで分析結果を提示してください

      **【出力形式と比率】**

      必ず以下の4つのセクションで分析結果を提示してください。
      各セクションは必ず見出し（【セクション名】）で始めてください。

      **1. 【あなたの気持ちを受け止めて】**
      全体の15%程度、2-3行
      - 短く、でも温かく気持ちを受け止める
      - 長々とした共感は避ける（依存を防ぐため）
      - 「あなたの感じていることは自然なことです」という受容

      **2. 【対話から見えてきたこと】**
      全体の25%程度、4-5行
      - 3回の対話を通じて浮かび上がった本質的な原因
      - ユーザー自身が「あ、そういうことか」と気づけるように提示
      - 押し付けではなく、「こんなことが見えてきました」という提示
      - 具体的な気づきを2-3個、箇条書きで

      **3. 【解決の方向性】**
      全体の30%程度、5-6行
      - この状況を変えていくための考え方・フレームワーク
      - WHY（なぜその方向性なのか）を明確に
      - WHAT（何を目指すのか）を具体的に
      - 「〜すべき」ではなく「〜という方向性があります」という提案
      - ユーザーが自分で考えられるような視点を提供

      **4. 【試してみてほしいこと】**
      全体の30%程度、5-6行
      - 明日から実践できる具体的なアクションを3-4個
      - 小さく始められること（ハードルを下げる）
      - HOW（具体的にどうやるか）とWHEN（いつやるか）を明確に
      - 「試してみて、自分の変化を観察してみてください」という自己観察を促す
      - 「正解」ではなく「実験」として提示

      ーーー
      お疲れさまでした。今日も自分と向き合えたこと、素晴らしいです。
      小さな一歩から始めてみてください。

      **【トーンとスタンス】**
      - 「〜してください」より「〜してみてはどうでしょう？」
      - 「これが答えです」より「こういう視点もあるかもしれません」
      - 「あなたならできる」という自己効力感を高める言葉を
      - 依存を生まない：過度な共感、過度な励まし、答えの押し付けを避ける
      - 自立を促す：自分で気づき、自分で選択し、自分で行動することを促す

      **【最重要】**
      - 絶対に質問をしないでください
      - 必ず上記の4セクション形式（【あなたの気持ちを受け止めて】【対話から見えてきたこと】【解決の方向性】【試してみてほしいこと】）で始めてください
      - 表面的な励ましではなく、本質的な洞察と実践的な解決策を提供してください
      - このツールはセルフコーチングツールです。ユーザーが自分で人生を変える力を引き出してください
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
