class HomeController < ApplicationController
  def index
    @chat_session = ChatSession.last || ChatSession.create!
  end
end
