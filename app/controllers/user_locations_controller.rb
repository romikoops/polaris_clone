class UserLocationsController < ApplicationController
  skip_before_action :require_authentication!
  skip_before_action :require_non_guest_authentication!

  def index
    user = User.find(params[:user_id])
    resp = Location.all_with_primary_for(user)

    response_handler(resp)
  end

  def create
    user = User.find(params[:user_id])
    location = Location.create!(JSON.parse(params[:new_location]))
    unless user_signed_in? && current_user.role.name.include?("admin")
    new_user_loc = user.user_locations.create!(primary: false, location_id: location.id)
    user_locations = user.user_locations
    response_handler(user_locations)
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
end
