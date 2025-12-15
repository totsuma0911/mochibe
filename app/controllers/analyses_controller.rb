class AnalysesController < ApplicationController
  before_action :set_chat_session, only: [ :show ]
  rescue_from ActiveRecord::RecordNotFound, with: :redirect_to_home

  def show
    @analysis = @chat_session.analysis

    unless @analysis
      redirect_to root_path, alert: "分析結果が見つかりませんでした。新しい分析を始めてください。"
    end
  end

  # 最新の分析結果を表示
  def latest
    guest_id = cookies.permanent.signed[:guest_id] ||= SecureRandom.uuid

    # 最新のAnalysisが存在するChatSessionを取得
    analysis_session = ChatSession.where(guest_id: guest_id)
                                   .joins(:analysis)
                                   .order(created_at: :desc)
                                   .first

    if analysis_session
      redirect_to chat_session_analysis_path(analysis_session)
    else
      # 分析結果がない場合、分析開始用のChatSessionを準備
      last_session = ChatSession.where(guest_id: guest_id).last

      if last_session && last_session.messages.exists?(step: 4)
        @chat_session = ChatSession.create!(guest_id: guest_id)
      else
        @chat_session = last_session || ChatSession.create!(guest_id: guest_id)
      end

      # 専用ページを表示
      render :no_result
    end
  end

  private

  def set_chat_session
    guest_id = cookies.permanent.signed[:guest_id]
    @chat_session = ChatSession.find(params[:chat_session_id])

    # 自分のセッションか確認（セキュリティ対策）
    unless @chat_session.guest_id == guest_id
      redirect_to root_path, alert: "このセッションにはアクセスできません"
      nil
    end
  end

  def redirect_to_home
    redirect_to root_path, alert: "セッションが見つかりませんでした。新しい分析を始めてください。"
  end
end
