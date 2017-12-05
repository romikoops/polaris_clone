class UserLocationsController < ApplicationController
  # before_action :require_login_and_correct_id

  def index
    user = User.find(params[:user_id])
    resp = Location.all_with_primary_for(user)

    response_handler(resp)
  end

  def create
    
  end

  def update
    user = User.find(params[:user_id])
    primary_uls = user.user_locations.where(primary: true)
    primary_uls.each do |ul|
      ul.update_attribute(:primary, false)
    end

    ul = UserLocation.find_by(user_id: params[:user_id], location_id: params[:id])
    ul.update_attribute(:primary, true)

    resp = Location.all_with_primary_for(user)

    response_handler(resp)
  end

  def destroy
    ul = UserLocation.find_by(user_id: params[:user_id], location_id: params[:id])
    ul.destroy
    
    response_handler({id: params[:id]})
  end

  private

  def require_login_and_correct_id
    unless user_signed_in? && current_user.id.to_s == params[:user_id]
      flash[:error] = "You are not authorized to access this section."
      redirect_to root_path
    end
  end
end
