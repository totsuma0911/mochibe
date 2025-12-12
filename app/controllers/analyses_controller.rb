class AnalysesController < ApplicationController
  before_action :set_chat_session
  rescue_from ActiveRecord::RecordNotFound, with: :redirect_to_home

  def show
    @analysis = @chat_session.analysis

    unless @analysis
      redirect_to root_path, alert: "分析結果が見つかりませんでした。新しい分析を始めてください。"
    end
  end

  private

  def set_chat_session
    @chat_session = ChatSession.find(params[:chat_session_id])
  end

  def redirect_to_home
    redirect_to root_path, alert: "セッションが見つかりませんでした。新しい分析を始めてください。"
  end
end
