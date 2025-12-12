Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check   # ヘルスチェック(/up)

  root "home#index"                                          # トップページ

  resources :users, only: %i[new create]                     # ユーザー登録
  resources :user_sessions, only: %i[new create destroy]     # ログイン/ログアウト

  resources :chat_sessions, only: %i[show create] do   # チャットセッション(一覧/詳細/作成)
    resources :messages, only: %i[create]                    #   メッセージ投稿
    resource :analysis, only: %i[show]                       #   分析結果
  end
end


