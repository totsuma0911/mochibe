# frozen_string_literal: true

class AddProviderUidIndexToUsers < ActiveRecord::Migration[7.2]
  def change
    # provider/uidの組み合わせでOAuthユーザーを一意に識別
    # NULLは許容（メール/パスワード登録ユーザー用）
    add_index :users, [:provider, :uid], unique: true, where: "provider IS NOT NULL"
  end
end
