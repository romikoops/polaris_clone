class UsersController < ApplicationController
  # before_action :require_login_and_correct_id
  include PricingTools
  def home
    @shipper = current_user

    @requested_shipments = @shipper.shipments.where(status: "requested")
    @open_shipments = @shipper.shipments.where(status: ["accepted", "in_progress"])
    @finished_shipments = @shipper.shipments.where(status: ["declined", "finished"])
    @pricings = get_user_pricings(@shipper.id)
    @contacts = @shipper.contacts
    @locations = @shipper.locations
    resp = {
      shipments:{
        requested: @requested_shipments,
        open: @open_shipments,
        finished: @finished_shipments
      },
      pricings: @pricings,
      contacts: @contacts,
      locations: @locations
    }
    response_handler(resp)
  end

  def account
    @user = current_user
    @locations = @user.locations

    return {locations: @locations}
  end
  

  def hubs
    @hubs = Hub.prepped(current_user)
    
    response_handler(@hubs)
  end

  private

  def require_login_and_correct_id
    unless user_signed_in? && current_user.id.to_s == params[:user_id]
      flash[:error] = "You are not authorized to access this section."
      redirect_to root_path
    end
  end
end
