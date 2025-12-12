class HomeController < ApplicationController
  def index
    guest_id = cookies.permanent[:guest_id] ||= SecureRandom.uuid
    @chat_session = ChatSession.where(guest_id: guest_id).last || ChatSession.create!(guest_id: guest_id)
  end
end
