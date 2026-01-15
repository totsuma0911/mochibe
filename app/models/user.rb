class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [:google_oauth2]

  has_many :chat_sessions

  def self.from_omniauth(auth)
    # 1. provider/uidで既存OAuthユーザーを検索
    user = find_by(provider: auth.provider, uid: auth.uid)
    if user
      user.instance_variable_set(:@newly_created, false)
      return user
    end

    # 2. メールで既存ユーザーを検索（メール/パスワード登録済みの場合）
    user = find_by(email: auth.info.email)
    if user
      # 既存アカウントにOAuth情報を紐付け
      user.update!(
        provider: auth.provider,
        uid: auth.uid,
        name: user.name.presence || auth.info.name,
        avatar_url: user.avatar_url.presence || auth.info.image
      )
      user.instance_variable_set(:@newly_created, false)
      return user
    end

    # 3. 完全に新規のユーザー
    user = create!(
      provider: auth.provider,
      uid: auth.uid,
      email: auth.info.email,
      password: Devise.friendly_token[0, 20],
      name: auth.info.name,
      avatar_url: auth.info.image
    )
    user.instance_variable_set(:@newly_created, true)
    user
  end

  def newly_created?
    @newly_created == true
  end
end


