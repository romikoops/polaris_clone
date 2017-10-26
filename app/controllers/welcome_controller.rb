class WelcomeController < ApplicationController
  def index
  	@shipper = current_user
  end
end