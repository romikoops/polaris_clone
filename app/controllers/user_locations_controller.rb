class UserLocationsController < ApplicationController
  # before_action :require_login_and_correct_id

  include Response

  def index
    user = User.find(params[:user_id])
    resp = user.locations

    json_response(resp, 200)
  end

  def create
    
  end

  def update
    
  end

  def destroy
    
  end

  private

  def require_login_and_correct_id
    unless user_signed_in? && current_user.id.to_s == params[:user_id]
      flash[:error] = "You are not authorized to access this section."
      redirect_to root_path
    end
  end
end
