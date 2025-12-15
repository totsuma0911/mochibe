Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check   # ヘルスチェック(/up)

  root "home#index"                                          # トップページ
  get "how_to_use", to: "home#how_to_use"                    # 使い方ガイド

  resources :users, only: %i[new create]                     # ユーザー登録
  resources :user_sessions, only: %i[new create destroy]     # ログイン/ログアウト

  resources :chat_sessions, only: %i[show create] do   # チャットセッション(一覧/詳細/作成)
    resources :messages, only: %i[create]                    #   メッセージ投稿
    resource :analysis, only: %i[show]                       #   分析結果
  end

  get "my_analysis", to: "analyses#latest"                   # 最新の分析結果
  get "new_analysis", to: "chat_sessions#new_session"        # 新規分析開始（常に新しいセッション）
end
