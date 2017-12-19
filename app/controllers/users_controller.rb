class UsersController < ApplicationController
  # before_action :require_login_and_correct_id

  def home
    @pricings = current_user.pricings
  end

  def account
    @user = current_user
    @locations = @user.locations

    return {locations: @locations}
  end
  def anon_login
      byebug
      pword = "guest_#{Time.now.to_i}#{rand(100)}"
      u = User.new(:first_name => "Guest", :email => "guest_#{Time.now.to_i}#{rand(100)}@example.com", :password => pword, :password_confirmation => pword, anonymous: true)
      # u.save!(:validate => false)
      byebug
      sign_in u

      sign_in u, :bypass => true 
  end

  private

  def require_login_and_correct_id
    unless user_signed_in? && current_user.id.to_s == params[:user_id]
      flash[:error] = "You are not authorized to access this section."
      redirect_to root_path
    end
  end
end
