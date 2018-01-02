class WelcomeController < ApplicationController
	skip_before_action :require_authentication!
	skip_before_action :require_non_guest_authentication!

  def index
  	@shipper = current_user
  end
end