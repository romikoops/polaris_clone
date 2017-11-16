class UsersController < ApplicationController
  # before_action :require_login_and_correct_id

  layout 'dashboard'

  def home
    @pricings = current_user.pricings
  end

  def account
    @user = current_user
  end

  private

  def require_login_and_correct_id
    unless user_signed_in? && current_user.id.to_s == params[:user_id]
      flash[:error] = "You are not authorized to access this section."
      redirect_to root_path
    end
  end
end
